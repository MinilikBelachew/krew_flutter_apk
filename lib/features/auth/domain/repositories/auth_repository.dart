import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> verifyLoginOtp(int userId, String otpCode);
  Future<void> resendLoginOtp(int userId);
  Future<void> logout();
  Future<bool> isAuthenticated();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String otp, String newPassword);
  Future<UserEntity> getMe();
}
