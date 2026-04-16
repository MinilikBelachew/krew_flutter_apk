import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Thrown when a login attempt requires 2FA verification.
class TwoFactorRequiredException implements Exception {
  final int userId;
  final String message;
  TwoFactorRequiredException({required this.userId, required this.message});
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final FlutterSecureStorage _storage;
  AuthRepositoryImpl(this._remoteDataSource, this._storage);

  @override
  Future<UserEntity> login(String email, String password) async {
    final data = await _remoteDataSource.login(email, password);

    // Handle 2FA challenge
    if (data['requires2FA'] == true || data['requiresOtp'] == true) {
      throw TwoFactorRequiredException(
        userId: (data['userId'] as num).toInt(),
        message: data['message'] as String? ?? 'Please enter your 2FA code',
      );
    }

    await _persistTokens(data);
    return _mapToUser(data, email: email);
  }

  @override
  Future<UserEntity> verifyLoginOtp(int userId, String otpCode) async {
    final data = await _remoteDataSource.verify2FALogin(userId, otpCode);
    await _persistTokens(data);
    return _mapToUser(data);
  }

  @override
  Future<void> resendLoginOtp(int userId) async {
    await _remoteDataSource.resendLoginOtp(userId);
  }

  @override
  Future<void> logout() async {
    try {
      await _storage.delete(key: 'access_token');
      await _storage.delete(key: 'refresh_token');
    } catch (e) {
      // Ignored
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      final token = await _storage.read(key: 'access_token');
      return token != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    await _remoteDataSource.resetPassword(email, otp, newPassword);
  }

  @override
  Future<UserEntity> getMe() async {
    final userData = await _remoteDataSource.getMe();
    return UserEntity(
      id: userData['id']?.toString() ?? '',
      email: userData['email'] ?? '',
      role: userData['role']?['name'] as String? ?? 'Mover',
      tenantId: userData['tenantId']?.toString(),
    );
  }

  // -- helpers --

  Future<void> _persistTokens(Map<String, dynamic> data) async {
    try {
      final token = data['token'] as String?;
      final refreshToken = data['refreshToken'] as String?;
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
      }
      if (refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: refreshToken);
      }
    } catch (e) {
      // Ignored
    }
  }

  UserEntity _mapToUser(Map<String, dynamic> data, {String? email}) {
    final userData = data['user'] as Map<String, dynamic>?;
    return UserEntity(
      id: userData?['id']?.toString() ?? '',
      email:
          email ??
          userData?['email']?.toString() ??
          data['email']?.toString() ??
          '',
      role: userData?['role']?['name'] as String? ?? '',
      tenantId: userData?['tenantId']?.toString(),
    );
  }
}
