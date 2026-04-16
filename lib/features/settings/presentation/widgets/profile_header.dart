import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileHeader extends StatelessWidget {
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? photoUrl;
  final bool isUploading;
  final VoidCallback onPhotoTap;

  const ProfileHeader({
    super.key,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    required this.photoUrl,
    required this.isUploading,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    final displayIdentity =
        (phone != null && phone!.isNotEmpty) ? phone! : fullName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: onPhotoTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isDarkMode ? const Color(0xFF262626) : Colors.grey[200],
                    image: hasPhoto
                        ? DecorationImage(
                            image: NetworkImage(photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    border: Border.all(
                      color:
                          isDarkMode ? const Color(0xFF262626) : Colors.white,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: !hasPhoto
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 48,
                          color:
                              isDarkMode ? Colors.grey[600] : Colors.grey[400],
                        )
                      : null,
                ),
                if (isUploading)
                  Container(
                    width: 104,
                    height: 104,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0x66000000),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Identity (Phone or Full Name)
          Text(
            displayIdentity,
            style: GoogleFonts.inter(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: isDarkMode ? Colors.white : const Color(0xFF111827),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),

          // Role (Normal grey text)
          Text(
            role,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDarkMode
                  ? const Color(0xFF9CA3AF)
                  : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }
}
