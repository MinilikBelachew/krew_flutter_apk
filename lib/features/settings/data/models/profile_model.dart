import 'package:movers/features/settings/domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  ProfileModel({
    required super.id,
    required super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.homePhone,
    super.address,
    super.unitNumber,
    super.twoFactorEnabled,
    super.role,
    super.photoUrl,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Attempt to parse photo structure if present (e.g. nested object with path or url)
    String? parsedPhotoUrl;
    if (json['photo'] is Map && json['photo']['path'] != null) {
      parsedPhotoUrl = json['photo']['path'];
    } else if (json['photoUrl'] != null) {
      parsedPhotoUrl = json['photoUrl'];
    } else if (json['avatarUrl'] != null) {
      parsedPhotoUrl = json['avatarUrl'];
    }

    if (parsedPhotoUrl != null) {
      final trimmed = parsedPhotoUrl.toString().trim();
      if (trimmed.isEmpty) {
        parsedPhotoUrl = null;
      } else if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        parsedPhotoUrl = trimmed;
      } else if (trimmed.startsWith('/')) {
        parsedPhotoUrl = 'https://movers-backend.learnica.net$trimmed';
      } else {
        parsedPhotoUrl = trimmed;
      }
    }

    return ProfileModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      phone: json['phone'],
      homePhone: json['homePhone'],
      address: json['address'],
      unitNumber: json['unitNumber'],
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      role: json['role']?['name'],
      photoUrl: parsedPhotoUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'homePhone': homePhone,
      'address': address,
      'unitNumber': unitNumber,
      'twoFactorEnabled': twoFactorEnabled,
      'photoUrl': photoUrl,
    };
  }
}
