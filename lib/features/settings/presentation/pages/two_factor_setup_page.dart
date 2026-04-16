import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import '../../../../core/utils/toast_service.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class TwoFactorSetupPage extends StatefulWidget {
  const TwoFactorSetupPage({super.key});

  @override
  State<TwoFactorSetupPage> createState() => _TwoFactorSetupPageState();
}

class _TwoFactorSetupPageState extends State<TwoFactorSetupPage> {
  final TextEditingController _tokenController = TextEditingController();
  bool _isSecretVisible = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileBloc>().state.profile;
    if (profile != null && !(profile.twoFactorEnabled)) {
      context.read<ProfileBloc>().add(Profile2FASetupRequested());
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  void _verifyAndEnable() {
    final secret = context.read<ProfileBloc>().state.twoFactorSecret;
    final token = _tokenController.text.trim();
    if (secret != null && token.isNotEmpty) {
      context.read<ProfileBloc>().add(
        Profile2FAEnableRequested(secret: secret, token: token),
      );
    }
  }

  void _disable2FA() {
    final token = _tokenController.text.trim();
    if (token.isNotEmpty) {
      context.read<ProfileBloc>().add(Profile2FADisableRequested(token: token));
    }
  }

  Widget _buildQrCode(String qrCodeDataUri) {
    try {
      final base64String = qrCodeDataUri.split(',').last;
      final bytes = base64Decode(base64String);
      return Image.memory(bytes, width: 200, height: 200, fit: BoxFit.cover);
    } catch (e) {
      return Container(
        width: 200,
        height: 200,
        color: AppColors.adaptiveNeutralBackground(context),
        child: const Center(child: Icon(Icons.broken_image, size: 50)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF111111) : Colors.white,
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.success) {
            if (state.backupCodes != null && state.backupCodes!.isNotEmpty) {
              ToastService.showSuccess(
                context,
                'Two-factor authentication is now active.',
              );
              _showBackupCodesDialog(state.backupCodes!);
            } else if (state.profile?.twoFactorEnabled == false &&
                state.twoFactorSecret == null) {
              ToastService.showSuccess(
                context,
                'Two-factor authentication has been disabled.',
              );
              context.pop();
            }
          } else if (state.status == ProfileStatus.failure) {
            ToastService.showError(
              context,
              state.errorMessage ?? 'Failed to process 2FA request',
            );
          }
        },
        builder: (context, state) {
          final isEnabled = state.profile?.twoFactorEnabled ?? false;
          final isLoading = state.status == ProfileStatus.loading;

          if (isLoading && state.twoFactorQrCode == null && !isEnabled) {
            return const _TwoFactorSkeleton();
          }

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
                            color: isDarkMode ? Colors.white : const Color(0xFF111827),
                            size: 26,
                          ),
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      Text(
                        'Two-Factor Auth',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDarkMode ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // ─── Main Content Card ───────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.adaptiveCardBackground(context),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      if (!isEnabled) ...[
                        Text(
                          'Enhance Your Security',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.adaptiveTextPrimary(context),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan the QR code below using your authenticator app (like Google Authenticator or Authy).',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.adaptiveTextSecondary(context),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        if (state.twoFactorQrCode != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _buildQrCode(state.twoFactorQrCode!),
                          ),
                        const SizedBox(height: 24),
                        if (state.twoFactorSecret != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Manual Setup Key',
                                        style: GoogleFonts.inter(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.adaptiveTextSecondary(context),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _isSecretVisible
                                            ? state.twoFactorSecret!
                                            : '•••• •••• •••• ••••',
                                        style: _isSecretVisible
                                            ? const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: 'monospace',
                                                letterSpacing: 1,
                                              )
                                            : GoogleFonts.inter(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.adaptiveTextPrimary(context),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _isSecretVisible = !_isSecretVisible;
                                          });
                                        },
                                        icon: Icon(
                                          _isSecretVisible
                                              ? Icons.visibility_off_rounded
                                              : Icons.visibility_rounded,
                                          size: 18,
                                          color: AppColors.adaptiveTextSecondary(context).withValues(alpha: 0.5),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(text: state.twoFactorSecret!),
                                          );
                                          ToastService.showSuccess(
                                            context,
                                            'Setup Key copied!',
                                          );
                                        },
                                        icon: Icon(
                                          Icons.copy_rounded,
                                          size: 18,
                                          color: AppColors.adaptiveTextSecondary(context).withValues(alpha: 0.5),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Enter this key into your authenticator app if you cannot scan the QR code.',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: AppColors.adaptiveTextSecondary(context).withValues(alpha: 0.6),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        const SizedBox(height: 32),
                      ] else ...[
                        Icon(
                          Icons.verified_user_rounded,
                          color: AppColors.primary,
                          size: 72,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          '2FA is Active',
                          style: GoogleFonts.inter(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.adaptiveTextPrimary(context),
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Your account is secured with two-factor authentication. To disable it, enter a token from your app.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.adaptiveTextSecondary(context),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],

                      // Token Entry
                      Text(
                        isEnabled ? 'Enter Code to Disable' : 'Enter 6-digit Code from your App',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adaptiveTextSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Hidden real TextField
                            Opacity(
                              opacity: 0,
                              child: TextField(
                                controller: _tokenController,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                autofocus: false,
                                onChanged: (v) => setState(() {}),
                                decoration: const InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                            // Visible Pin Slots
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                final char = _tokenController.text.length > index
                                    ? _tokenController.text[index]
                                    : '';
                                final isFocused = _tokenController.text.length == index;

                                return Container(
                                  width: 42,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.white.withValues(alpha: 0.05)
                                        : Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isFocused
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    char,
                                    style: GoogleFonts.inter(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.adaptiveTextPrimary(context),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : (isEnabled ? _disable2FA : _verifyAndEnable),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18),
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
                                  isEnabled ? 'Disable 2FA' : 'Verify & Enable',
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
  }

  void _showBackupCodesDialog(List<String> codes) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Backup Codes',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppColors.adaptiveTextPrimary(context),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Please save these codes in a secure location. This is the ONLY time they will be shown.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.red[700]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              color: AppColors.adaptiveNeutralBackground(context),
              child: SelectableText(
                codes.join('\n'),
                style: const TextStyle(
                  fontSize: 16,
                  letterSpacing: 2,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop();
            },
            child: const Text('I saved them'),
          ),
        ],
      ),
    );
  }
}

class _TwoFactorSkeleton extends StatefulWidget {
  const _TwoFactorSkeleton();

  @override
  State<_TwoFactorSkeleton> createState() => _TwoFactorSkeletonState();
}

class _TwoFactorSkeletonState extends State<_TwoFactorSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        final base = Color.lerp(
          AppColors.skeletonBase(context),
          AppColors.skeletonHighlight(context),
          t,
        )!;

        Widget box({double? w, required double h, double r = 12}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(r),
          ),
        );

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              box(w: 200, h: 24, r: 10),
              const SizedBox(height: 12),
              box(w: double.infinity, h: 14, r: 8),
              const SizedBox(height: 6),
              box(w: 250, h: 14, r: 8),
              const SizedBox(height: 32),
              box(w: 232, h: 232, r: 16), // QR code placeholder
              const SizedBox(height: 24),
              box(w: 220, h: 14, r: 8), // Secret/Manual key placeholder
              const SizedBox(height: 48),
              box(w: double.infinity, h: 64, r: 12), // Token field placeholder
              const SizedBox(height: 32),
              box(w: double.infinity, h: 56, r: 12), // Button placeholder
            ],
          ),
        );
      },
    );
  }
}
