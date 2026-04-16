import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class ProfileFetchRequested extends ProfileEvent {}

class ProfileUpdateRequested extends ProfileEvent {
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? homePhone;
  final String? address;
  final String? unitNumber;

  const ProfileUpdateRequested({
    this.firstName,
    this.lastName,
    this.phone,
    this.homePhone,
    this.address,
    this.unitNumber,
  });

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    phone,
    homePhone,
    address,
    unitNumber,
  ];
}

class ProfilePhotoUpdateRequested extends ProfileEvent {
  final String filePath;

  const ProfilePhotoUpdateRequested({required this.filePath});

  @override
  List<Object?> get props => [filePath];
}

class Profile2FASetupRequested extends ProfileEvent {}

class Profile2FAEnableRequested extends ProfileEvent {
  final String secret;
  final String token;

  const Profile2FAEnableRequested({required this.secret, required this.token});

  @override
  List<Object?> get props => [secret, token];
}

class Profile2FADisableRequested extends ProfileEvent {
  final String token;

  const Profile2FADisableRequested({required this.token});

  @override
  List<Object?> get props => [token];
}

class ProfilePasswordChangeRequested extends ProfileEvent {
  final String oldPassword;
  final String password;

  const ProfilePasswordChangeRequested({
    required this.oldPassword,
    required this.password,
  });

  @override
  List<Object?> get props => [oldPassword, password];
}
