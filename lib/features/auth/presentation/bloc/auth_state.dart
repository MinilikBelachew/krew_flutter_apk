import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  requiresLoginOtp,
  failure,
  forgotPasswordSent,
  resetPasswordSuccess,
}

final class AuthState extends Equatable {
  final AuthStatus status;
  final String? errorMessage;
  final UserEntity? user;
  final int? pendingOtpUserId;
  final String? pendingOtpEmail;
  final String? pendingOtpMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.errorMessage,
    this.user,
    this.pendingOtpUserId,
    this.pendingOtpEmail,
    this.pendingOtpMessage,
  });

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    user,
    pendingOtpUserId,
    pendingOtpEmail,
    pendingOtpMessage,
  ];

  AuthState copyWith({
    AuthStatus? status,
    String? errorMessage,
    UserEntity? user,
    int? pendingOtpUserId,
    String? pendingOtpEmail,
    String? pendingOtpMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
      pendingOtpUserId: pendingOtpUserId ?? this.pendingOtpUserId,
      pendingOtpEmail: pendingOtpEmail ?? this.pendingOtpEmail,
      pendingOtpMessage: pendingOtpMessage ?? this.pendingOtpMessage,
    );
  }
}
