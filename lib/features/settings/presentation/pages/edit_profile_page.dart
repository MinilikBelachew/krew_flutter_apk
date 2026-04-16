import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/utils/toast_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _homePhoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _unitNumberController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
    _phoneController = TextEditingController(text: profile?.phone ?? '');
    _homePhoneController = TextEditingController(
      text: profile?.homePhone ?? '',
    );
    _addressController = TextEditingController(text: profile?.address ?? '');
    _unitNumberController = TextEditingController(
      text: profile?.unitNumber ?? '',
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _homePhoneController.dispose();
    _addressController.dispose();
    _unitNumberController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    context.read<ProfileBloc>().add(
      ProfileUpdateRequested(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        phone: _phoneController.text.trim(),
        homePhone: _homePhoneController.text.trim(),
        address: _addressController.text.trim(),
        unitNumber: _unitNumberController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state.status == ProfileStatus.success) {
          ToastService.showSuccess(context, 'Profile updated successfully');
          context.pop();
        } else if (state.status == ProfileStatus.failure) {
          ToastService.showError(
            context,
            state.errorMessage ?? 'Failed to update profile',
          );
        }
      },
      builder: (context, state) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final isLoading = state.status == ProfileStatus.loading;

        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              Widget field(Widget child) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: child,
                );
              }

              final firstName = field(
                _buildTextField(context, 'First Name', _firstNameController),
              );
              final lastName = field(
                _buildTextField(context, 'Last Name', _lastNameController),
              );
              final phone = field(
                _buildTextField(
                  context,
                  'Phone Number',
                  _phoneController,
                  keyboardType: TextInputType.phone,
                ),
              );
              final homePhone = field(
                _buildTextField(
                  context,
                  'Home Phone',
                  _homePhoneController,
                  keyboardType: TextInputType.phone,
                ),
              );
              final address = field(
                _buildTextField(context, 'Address', _addressController),
              );
              final unitNumber = field(
                _buildTextField(context, 'Unit Number', _unitNumberController),
              );

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // ─── Top Bar ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.only(top: 24, bottom: 12),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => context.pop(),
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: isDarkMode
                                    ? Colors.white
                                    : const Color(0xFF111827),
                                size: 26,
                              ),
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(8),
                            ),
                          ),
                          Text(
                            'Edit Profile',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF111827),
                              letterSpacing: -0.4,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ─── Form Card ───────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.adaptiveCardBackground(context),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isWide)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      firstName,
                                      phone,
                                      address,
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    children: [
                                      lastName,
                                      homePhone,
                                      unitNumber,
                                    ],
                                  ),
                                ),
                              ],
                            )
                          else ...[
                            firstName,
                            lastName,
                            phone,
                            homePhone,
                            address,
                            unitNumber,
                          ],
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Save Changes',
                                      style: GoogleFonts.inter(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.1,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.adaptiveTextSecondary(context),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.adaptiveTextPrimary(context),
            fontWeight: FontWeight.w500,
          ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        filled: true,
                        fillColor: AppColors.adaptiveCardBackground(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDarkMode
                                ? Colors.white.withValues(alpha: 0.18)
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
  }
}
