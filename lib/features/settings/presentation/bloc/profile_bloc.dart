import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc(this._profileRepository) : super(const ProfileState()) {
    on<ProfileFetchRequested>(_onFetchRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfilePhotoUpdateRequested>(_onPhotoUpdateRequested);
    on<Profile2FASetupRequested>(_on2FASetupRequested);
    on<Profile2FAEnableRequested>(_on2FAEnableRequested);
    on<Profile2FADisableRequested>(_on2FADisableRequested);
    on<ProfilePasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onPhotoUpdateRequested(
    ProfilePhotoUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isPhotoUploading: true, errorMessage: null));
    try {
      final profile = await _profileRepository.updateProfilePhoto(
        event.filePath,
      );
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: profile,
          isPhotoUploading: false,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
          isPhotoUploading: false,
        ),
      );
    }
  }

  Future<void> _onFetchRequested(
    ProfileFetchRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileRepository.getProfile();
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final profile = await _profileRepository.updateProfile(
        firstName: event.firstName,
        lastName: event.lastName,
        phone: event.phone,
        homePhone: event.homePhone,
        address: event.address,
        unitNumber: event.unitNumber,
      );
      emit(state.copyWith(status: ProfileStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _on2FASetupRequested(
    Profile2FASetupRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final setupData = await _profileRepository.setup2FA();
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          twoFactorSecret: setupData['secret'],
          twoFactorQrCode: setupData['qrCode'],
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _on2FAEnableRequested(
    Profile2FAEnableRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      final enableData = await _profileRepository.enable2FA(
        event.secret,
        event.token,
      );

      // Update profile locally to show 2FA is enabled
      final updatedProfile = state.profile?.copyWith(twoFactorEnabled: true);

      final dynamic rawBackupCodes = enableData['backupCodes'];
      List<String>? backupCodesList;
      if (rawBackupCodes is List) {
        backupCodesList = rawBackupCodes.map((e) => e.toString()).toList();
      }

      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: updatedProfile,
          backupCodes: backupCodesList,
          twoFactorSecret: null,
          twoFactorQrCode: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _on2FADisableRequested(
    Profile2FADisableRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    try {
      await _profileRepository.disable2FA(event.token);
      final updatedProfile = state.profile?.copyWith(twoFactorEnabled: false);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          profile: updatedProfile,
          backupCodes: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onPasswordChangeRequested(
    ProfilePasswordChangeRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    try {
      await _profileRepository.changePassword(
        oldPassword: event.oldPassword,
        password: event.password,
      );
      emit(state.copyWith(status: ProfileStatus.success));
    } catch (e) {
      emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
