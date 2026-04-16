import 'package:dio/dio.dart';
import 'package:movers/core/network/dio_client.dart';
import '../models/auth_models.dart';

abstract class AuthRemoteDataSource {
  /// Returns raw JSON map. Callers must check 'requires2FA' key.
  Future<Map<String, dynamic>> login(String email, String password);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<Map<String, dynamic>> getMe();

  /// Verify 2FA token after login challenge.
  Future<Map<String, dynamic>> verify2FALogin(int userId, String token);

  /// Resend (or no-op if backend doesn't support it).
  Future<void> resendLoginOtp(int userId);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final request = LoginRequestModel(email: email, password: password);
    final response = await _dioClient.dio.post(
      '/api/v1/auth/email/login',
      data: request.toJson(),
    );
    // Return raw data — caller handles both 2FA challenge and success cases
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> verify2FALogin(int userId, String token) async {
    final response = await _dioClient.dio.post(
      '/api/v1/auth/verify-login-otp',
      data: {'userId': userId, 'otpCode': token},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<void> resendLoginOtp(int userId) async {
    final response = await _dioClient.dio.post(
      '/api/v1/auth/resend-login-otp',
      data: {'userId': userId},
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Resend OTP failed',
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/auth/forgot/password',
        data: {'email': email},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Forgot password request failed',
        );
      }
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _dioClient.dio.post(
        '/api/v1/auth/reset/password',
        data: {'email': email, 'otp': otp, 'password': newPassword},
      );
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Reset password failed',
        );
      }
    } on DioException catch (_) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getMe() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/auth/me');
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          message: 'Failed to fetch user data',
        );
      }
    } on DioException catch (_) {
      rethrow;
    }
  }
}
