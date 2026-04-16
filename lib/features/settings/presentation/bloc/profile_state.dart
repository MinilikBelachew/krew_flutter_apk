import 'package:equatable/equatable.dart';
import '../../domain/entities/profile_entity.dart';

enum ProfileStatus { initial, loading, success, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final ProfileEntity? profile;
  final String? errorMessage;
  final bool isPhotoUploading;

  // 2FA Setup Data
  final String? twoFactorSecret;
  final String? twoFactorQrCode;
  final List<String>? backupCodes;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.profile,
    this.errorMessage,
    this.isPhotoUploading = false,
    this.twoFactorSecret,
    this.twoFactorQrCode,
    this.backupCodes,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    ProfileEntity? profile,
    String? errorMessage,
    bool? isPhotoUploading,
    String? twoFactorSecret,
    String? twoFactorQrCode,
    List<String>? backupCodes,
  }) {
    return ProfileState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      errorMessage: errorMessage ?? this.errorMessage,
      isPhotoUploading: isPhotoUploading ?? this.isPhotoUploading,
      twoFactorSecret: twoFactorSecret ?? this.twoFactorSecret,
      twoFactorQrCode: twoFactorQrCode ?? this.twoFactorQrCode,
      backupCodes: backupCodes ?? this.backupCodes,
    );
  }

  @override
  List<Object?> get props => [
    status,
    profile,
    errorMessage,
    isPhotoUploading,
    twoFactorSecret,
    twoFactorQrCode,
    backupCodes,
  ];
}
