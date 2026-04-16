import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Handles JWT token injection, silent token refresh on 401 errors,
/// and session logout when the refresh token is also expired.
///
/// Uses a [Completer] to ensure only one refresh request is made even when
/// multiple concurrent API calls fail with 401 at the same time.
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  /// Called when a session is truly expired (refresh token is invalid too).
  /// Use this to update the AuthBloc and redirect the user to login.
  final void Function()? onLogout;

  static bool _isRefreshing = false;
  static Completer<bool>? _refreshCompleter;

  AuthInterceptor(this._storage, {this.onLogout});

  // ── Request ──────────────────────────────────────────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  // ── Error (Token Refresh Logic) ───────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Only handle 401 (Unauthorized) and 403 (Forbidden) security errors.
    if (err.response?.statusCode != 401 && err.response?.statusCode != 403) {
      return handler.next(err);
    }

    final path = err.requestOptions.path;

    // Do not attempt refresh for auth endpoints — it will loop.
    if (path.contains('/auth/refresh') || path.contains('/auth/email/login')) {
      return _logout(err, handler);
    }

    // If a refresh is already running, wait for it to finish then retry.
    if (_isRefreshing) {
      final refreshed = await _refreshCompleter!.future;
      if (refreshed) {
        return _retryRequest(err.requestOptions, handler);
      } else {
        return _logout(err, handler);
      }
    }

    // This is the first request to hit 401 — start the refresh flow.
    _isRefreshing = true;
    _refreshCompleter = Completer<bool>();

    try {
      final refreshed = await _attemptRefresh(err.requestOptions.baseUrl);

      _refreshCompleter!.complete(refreshed);
      _isRefreshing = false;
      _refreshCompleter = null;

      if (refreshed) {
        return _retryRequest(err.requestOptions, handler);
      } else {
        return _logout(err, handler);
      }
    } catch (e) {
      // Refresh failed due to a network error, not a security rejection.
      // We do NOT logout. We just fail the original request so the user can retry.
      _refreshCompleter!.complete(false); // Other concurrent requests should fail
      _isRefreshing = false;
      _refreshCompleter = null;
      return handler.next(err);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  /// Calls the refresh endpoint and persists new tokens.
  /// Returns true if successful, false otherwise.
  Future<bool> _attemptRefresh(String baseUrl) async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      // Use a fresh Dio (no interceptors) to avoid recursion.
      // Important: Use short timeouts here to avoid hanging the app.
      final refreshDio = Dio(BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
      ));
      
      final response = await refreshDio.post(
        '/api/v1/auth/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      final newAccessToken = response.data['token'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;

      if (newAccessToken == null) return false;

      await _storage.write(key: 'access_token', value: newAccessToken);
      if (newRefreshToken != null) {
        await _storage.write(key: 'refresh_token', value: newRefreshToken);
      }

      return true;
    } on DioException catch (e) {
      // If the server explicitly rejected the refresh token (401/403), 
      // then the session is truly dead → logout.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return false;
      }
      // If it's a network error (timeout, no internet), do NOT return false.
      // Instead, we throw to let the caller handle the connection failure 
      // without wiping the user's login session.
      rethrow;
    } catch (_) {
      return false;
    }
  }

  /// Retries the original request with the freshly persisted access token.
  Future<void> _retryRequest(
    RequestOptions opts,
    ErrorInterceptorHandler handler,
  ) async {
    try {
      final newToken = await _storage.read(key: 'access_token');
      final headers = Map<String, dynamic>.from(opts.headers);
      headers['Authorization'] = 'Bearer $newToken';

      final retryDio = Dio(BaseOptions(baseUrl: opts.baseUrl));
      final response = await retryDio.request(
        opts.path,
        data: opts.data,
        queryParameters: opts.queryParameters,
        options: Options(
          method: opts.method,
          headers: headers,
          contentType: opts.contentType,
          responseType: opts.responseType,
        ),
      );

      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  /// Clears stored tokens and notifies the app to kick the user to login.
  Future<void> _logout(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    onLogout?.call();
    return handler.next(err);
  }
}
