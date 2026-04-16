import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:movers/core/services/dispatch_tracking_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final DispatchTrackingService? _dispatchTrackingService;

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthBloc(
    this._authRepository, {
    DispatchTrackingService? dispatchTrackingService,
  }) : _dispatchTrackingService = dispatchTrackingService,
       super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthVerifyLoginOtpRequested>(_onVerifyLoginOtpRequested);
    on<AuthResendLoginOtpRequested>(_onResendLoginOtpRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onResetPasswordRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final authenticated = await _authRepository.isAuthenticated();
    if (authenticated) {
      try {
        final biometricEnabled =
            (await _storage.read(key: 'biometric_enabled')) == 'true';

        if (biometricEnabled) {
          final supported = await _localAuth.isDeviceSupported();
          final canCheck = await _localAuth.canCheckBiometrics;
          if (supported && canCheck) {
            final didAuth = await _localAuth.authenticate(
              localizedReason: 'Unlock Movers',
              options: const AuthenticationOptions(
                biometricOnly: true,
                stickyAuth: true,
              ),
            );
            if (!didAuth) {
              emit(
                state.copyWith(status: AuthStatus.unauthenticated, user: null),
              );
              return;
            }
          }
        }

        final user = await _authRepository.getMe();
        emit(state.copyWith(status: AuthStatus.authenticated, user: user));
      } on DioException catch (e) {
        // Only clear the session when the server explicitly rejects our token.
        // A network timeout or no-internet error should NOT log the user out.
        final status = e.response?.statusCode;
        if (status == 401 || status == 403) {
          await _authRepository.logout();
          emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
        } else {
          // Network/server error — keep the cached session, let the user retry.
          emit(
            state.copyWith(
              status: AuthStatus.authenticated,
              user:
                  null, // user data couldn't be re-fetched; pages should handle null gracefully
              errorMessage:
                  'Could not connect to server. Showing cached session.',
            ),
          );
        }
      } catch (e) {
        // Unknown error — log out to be safe.
        await _authRepository.logout();
        emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
      }
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.login(event.email, event.password);
      emit(state.copyWith(status: AuthStatus.authenticated, user: user));
    } on DioException catch (e) {
      String message = 'Login failed';

      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        message = 'Server connection timed out. Please check your internet.';
      } else if (e.response?.data != null && e.response?.data is Map) {
        final data = e.response!.data as Map;

        final requiresOtp = data['requiresOtp'] == true;
        final requires2FA = data['requires2FA'] == true;
        if (requiresOtp || requires2FA) {
          emit(
            state.copyWith(
              status: AuthStatus.requiresLoginOtp,
              pendingOtpUserId: data['userId'] is int
                  ? data['userId'] as int
                  : int.tryParse(data['userId']?.toString() ?? ''),
              pendingOtpEmail: data['email']?.toString(),
              pendingOtpMessage: data['message']?.toString(),
              errorMessage: null,
            ),
          );
          return;
        }

        if (data.containsKey('errors')) {
          final errors = data['errors'] as Map;
          if (errors.containsKey('email')) {
            message = 'Email address not found';
          } else if (errors.containsKey('password')) {
            message = 'Incorrect password';
          } else {
            message = errors.values.first.toString();
          }
        } else if (data.containsKey('message')) {
          message = data['message'].toString();
        }
      } else {
        message = 'Network error: ${e.message ?? 'Unknown'}';
      }

      emit(state.copyWith(status: AuthStatus.failure, errorMessage: message));
    } on TwoFactorRequiredException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.requiresLoginOtp,
          pendingOtpUserId: e.userId,
          pendingOtpMessage: e.message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'An unexpected error occurred: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onVerifyLoginOtpRequested(
    AuthVerifyLoginOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final user = await _authRepository.verifyLoginOtp(
        event.userId,
        event.otpCode,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          pendingOtpUserId: null,
          pendingOtpEmail: null,
          pendingOtpMessage: null,
        ),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (e.message ?? 'OTP verification failed');
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: msg));
    } catch (e) {
      emit(
        state.copyWith(status: AuthStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onResendLoginOtpRequested(
    AuthResendLoginOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _authRepository.resendLoginOtp(event.userId);
      emit(state.copyWith(status: AuthStatus.requiresLoginOtp));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'Failed to resend OTP',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _dispatchTrackingService?.stop();
    await _authRepository.logout();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.forgotPassword(event.email);
      emit(state.copyWith(status: AuthStatus.forgotPasswordSent));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: e.response?.data?['message'] ?? 'Failed to send OTP',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }

  Future<void> _onResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      await _authRepository.resetPassword(
        event.email,
        event.otp,
        event.password,
      );
      emit(state.copyWith(status: AuthStatus.resetPasswordSuccess));
    } on DioException catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage:
              e.response?.data?['message'] ?? 'Failed to reset password',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.failure,
          errorMessage: 'An unexpected error occurred',
        ),
      );
    }
  }
}
