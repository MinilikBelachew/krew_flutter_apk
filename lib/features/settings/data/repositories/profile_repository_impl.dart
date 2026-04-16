import '../../../../core/network/dio_client.dart';
import 'package:dio/dio.dart';
import '../models/profile_model.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final DioClient _dioClient;

  ProfileRepositoryImpl(this._dioClient);

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final response = await _dioClient.dio.get('/api/v1/auth/me');
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfilePhoto(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final uploadRes = await _dioClient.dio.post(
        '/api/v1/files/upload',
        data: formData,
      );

      final uploaded = uploadRes.data;
      final fileObj = uploaded is Map ? uploaded['file'] : null;
      final fileId = fileObj is Map
          ? fileObj['id']?.toString()
          : (uploaded is Map ? uploaded['id']?.toString() : null);
      if (fileId == null || fileId.isEmpty) {
        throw Exception('Upload failed: missing file id');
      }

      final response = await _dioClient.dio.patch(
        '/api/v1/auth/me',
        data: {
          'photo': {'id': fileId},
        },
      );

      return ProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? homePhone,
    String? address,
    String? unitNumber,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (firstName != null) data['firstName'] = firstName;
      if (lastName != null) data['lastName'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (homePhone != null) data['homePhone'] = homePhone;
      if (address != null) data['address'] = address;
      if (unitNumber != null) data['unitNumber'] = unitNumber;

      final response = await _dioClient.dio.patch(
        '/api/v1/auth/me',
        data: data,
      );
      return ProfileModel.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> setup2FA() async {
    try {
      // Get user ID first
      final profile = await getProfile();
      final response = await _dioClient.dio.post(
        '/api/v1/auth/2fa/setup/${profile.id}',
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> enable2FA(String secret, String token) async {
    try {
      final profile = await getProfile();
      final response = await _dioClient.dio.post(
        '/api/v1/auth/2fa/enable/${profile.id}',
        data: {'secret': secret, 'token': token},
      );
      return response.data as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> disable2FA(String token) async {
    try {
      final profile = await getProfile();
      await _dioClient.dio.post(
        '/api/v1/auth/2fa/disable/${profile.id}',
        data: {'token': token},
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String password,
  }) async {
    try {
      await _dioClient.dio.post(
        '/api/v1/auth/change-password',
        data: {'oldPassword': oldPassword, 'password': password},
      );
    } catch (e) {
      rethrow;
    }
  }
}
