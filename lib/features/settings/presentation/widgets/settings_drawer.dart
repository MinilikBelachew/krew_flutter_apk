import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:movers/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movers/features/auth/presentation/bloc/auth_event.dart';
import 'package:movers/features/auth/presentation/bloc/auth_state.dart';
import 'package:movers/features/settings/presentation/bloc/profile_bloc.dart';
import 'package:movers/features/settings/presentation/bloc/profile_state.dart';
import 'package:movers/features/settings/presentation/bloc/profile_event.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/network/dio_client.dart';
import 'package:movers/core/services/dispatch_tracking_service.dart';

import 'profile_header.dart';
import 'section_group.dart';
import 'settings_tile.dart';
import 'appearance_section.dart';
import 'tracking_section.dart';
import 'settings_skeleton.dart';
import 'bottom_sheet_tile.dart';

class SettingsDrawer extends StatelessWidget {
  const SettingsDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            context.go('/login');
          }
        },
        builder: (context, authState) {
          return BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, profileState) {
              final isLoading = profileState.status == ProfileStatus.loading ||
                  profileState.profile == null;

              if (isLoading) {
                return const SafeArea(child: SettingsSkeleton());
              }

              final profile = profileState.profile;
              final email = profile?.email ?? authState.user?.email ?? 'User';
              final firstName = profile?.firstName ?? '';
              final lastName = profile?.lastName ?? '';
              final fullName = firstName.isNotEmpty || lastName.isNotEmpty
                  ? '$firstName $lastName'.trim()
                  : email;
              final role = profile?.role ?? authState.user?.role ?? 'Mover';

              return SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ─── Header ───────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                        child: Row(
                          children: [
                            Text(
                              'Settings',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.adaptiveTextPrimary(context),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.close_rounded,
                                color: AppColors.adaptiveTextSecondary(context),
                                size: 22,
                              ),
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),

                      // ─── Profile Hero ──────────────────────────────────
                      ProfileHeader(
                        fullName: fullName,
                        email: email,
                        role: role,
                        phone: profile?.phone,
                        photoUrl: profile?.photoUrl,
                        isUploading: profileState.isPhotoUploading,
                        onPhotoTap: () => _showPhotoPicker(context),
                      ),

                      // ─── Account Section ───────────────────────────────
                      SectionGroup(
                        label: 'Account',
                        children: [
                          SettingsTile(
                            icon: Icons.person_outline_rounded,
                            title: 'Edit Profile',
                            onTap: () {
                              context.pop(); // Close drawer
                              context.push('/edit-profile');
                            },
                          ),
                          SettingsTile(
                            icon: Icons.security_outlined,
                            title: 'Two-Factor Auth',
                            onTap: () {
                              context.pop();
                              context.push('/2fa-setup');
                            },
                          ),
                          SettingsTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Change Password',
                            onTap: () {
                              context.pop();
                              context.push('/change-password');
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ─── Activity Section ──────────────────────────────
                      SectionGroup(
                        label: 'Activity',
                        children: [
                          SettingsTile(
                            icon: Icons.history_outlined,
                            title: 'Job History',
                            onTap: () {
                              context.pop();
                              context.push('/history');
                            },
                            isLast: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // ─── Appearance Section ────────────────────────────
                      const AppearanceSection(),
                      const SizedBox(height: 8),

                      // ─── Tracking & Security Section ───────────────────
                      TrackingSection(
                        trackingService: DispatchTrackingService(
                          storage: const FlutterSecureStorage(),
                          dioClient: context.read<DioClient>(),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ─── Logout Button ─────────────────────────────────
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SizedBox(
                            width: 250, // Reduced width
                            child: ElevatedButton(
                              onPressed: () => _showLogoutConfirmation(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                'Log Out',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.adaptiveCardBackground(context),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          actionsPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.error,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Log Out',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.adaptiveTextPrimary(context),
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to log out of your account?',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.adaptiveTextSecondary(context),
              height: 1.4,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.adaptiveBorder(context),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      foregroundColor: AppColors.adaptiveTextPrimary(context),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: Text(
                      'Log Out',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPhotoPicker(BuildContext context) async {
    final picker = ImagePicker();

    Future<void> pick(ImageSource source) async {
      final x = await picker.pickImage(source: source, imageQuality: 85);
      if (x == null) return;
      if (!context.mounted) return;
      context.read<ProfileBloc>().add(
        ProfilePhotoUpdateRequested(filePath: x.path),
      );
    }

    if (!context.mounted) return;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveBorder(context),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Change Profile Photo',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.adaptiveTextPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 16),
                  BottomSheetTile(
                    icon: Icons.camera_alt_outlined,
                    label: 'Take Photo',
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await pick(ImageSource.camera);
                    },
                  ),
                  BottomSheetTile(
                    icon: Icons.photo_library_outlined,
                    label: 'Choose from Library',
                    onTap: () async {
                      Navigator.of(ctx).pop();
                      await pick(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
