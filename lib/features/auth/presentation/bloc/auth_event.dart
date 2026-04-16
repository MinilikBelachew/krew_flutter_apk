import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  final String? phoneNumber;
  final String? pin;

  const AuthLoginRequested({
    required this.email,
    required this.password,
    this.phoneNumber,
    this.pin,
  });

  @override
  List<Object> get props => [email, password, ?phoneNumber, ?pin];
}

final class AuthLogoutRequested extends AuthEvent {}

final class AuthCheckRequested extends AuthEvent {}

final class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested(this.email);

  @override
  List<Object> get props => [email];
}

final class AuthResetPasswordRequested extends AuthEvent {
  final String email;
  final String otp;
  final String password;

  const AuthResetPasswordRequested({
    required this.email,
    required this.otp,
    required this.password,
  });

  @override
  List<Object> get props => [email, otp, password];
}

final class AuthVerifyLoginOtpRequested extends AuthEvent {
  final int userId;
  final String otpCode;

  const AuthVerifyLoginOtpRequested({
    required this.userId,
    required this.otpCode,
  });

  @override
  List<Object> get props => [userId, otpCode];
}

final class AuthResendLoginOtpRequested extends AuthEvent {
  final int userId;

  const AuthResendLoginOtpRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}
