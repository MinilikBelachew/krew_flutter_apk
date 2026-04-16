import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/theme.dart';

class HomeHeaderPill extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationTap;

  const HomeHeaderPill({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.hasUnreadNotifications,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: AppColors.adaptiveBorder(context).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.2 : 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Scaffold.of(context).openDrawer(),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Icon(
                Icons.menu_rounded,
                color: AppColors.adaptiveTextPrimary(
                  context,
                ).withValues(alpha: 0.7),
                size: 26,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.white.withValues(alpha: 0.01)
                    : Colors.white,
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: AppColors.adaptiveBorder(
                    context,
                  ).withValues(alpha: isDarkMode ? 0.6 : 0.8),
                  width: 1.2,
                ),
              ),
              child: Center(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearchChanged,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.adaptiveTextPrimary(context),
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.local_shipping_outlined,
                      color: AppColors.adaptiveTextSecondary(
                        context,
                      ).withValues(alpha: 0.5),
                      size: 20,
                    ),
                    hintText: 'Search jobs...',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.adaptiveTextSecondary(
                        context,
                      ).withValues(alpha: 0.5),
                      fontSize: 16,
                      letterSpacing: -0.2,
                    ),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          InkWell(
            onTap: onNotificationTap,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.adaptiveTextPrimary(
                      context,
                    ).withValues(alpha: 0.7),
                    size: 24,
                  ),
                  if (hasUnreadNotifications)
                    Positioned(
                      top: -2,
                      right: -2,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
