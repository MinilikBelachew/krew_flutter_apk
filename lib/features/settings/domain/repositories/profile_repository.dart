import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();
  Future<ProfileEntity> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? homePhone,
    String? address,
    String? unitNumber,
  });

  Future<ProfileEntity> updateProfilePhoto(String filePath);

  // 2FA Methods
  Future<Map<String, dynamic>> setup2FA();
  Future<Map<String, dynamic>> enable2FA(String secret, String token);
  Future<void> disable2FA(String token);

  Future<void> changePassword({
    required String oldPassword,
    required String password,
  });
}
