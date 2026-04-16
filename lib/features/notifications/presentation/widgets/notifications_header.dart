import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';

class NotificationsHeader extends StatelessWidget {
  final int unreadCount;
  final bool isUpdating;
  final VoidCallback onMarkAllRead;
  final VoidCallback? onBack;

  const NotificationsHeader({
    super.key,
    required this.unreadCount,
    required this.isUpdating,
    required this.onMarkAllRead,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = isUpdating || unreadCount == 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back_rounded,
              size: 26,
              color: AppColors.adaptiveTextPrimary(context),
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notifications',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.adaptiveTextPrimary(context),
                  letterSpacing: -0.5,
                ),
              ),
              if (unreadCount > 0) ...[
                Text(
                  '$unreadCount unread',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.adaptiveTextSecondary(context).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ],
          ),
          const Spacer(),
          // Mark all read button
          GestureDetector(
            onTap: disabled ? null : onMarkAllRead,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: disabled
                    ? AppColors.adaptiveNeutralBackground(context).withValues(alpha: 0.5)
                    : AppColors.adaptiveNeutralBackground(context),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.adaptiveBorder(context).withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isUpdating)
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.adaptiveTextPrimary(context),
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.done_all_rounded,
                      size: 14,
                      color: disabled
                          ? AppColors.adaptiveTextSecondary(context).withValues(alpha: 0.5)
                          : AppColors.adaptiveTextPrimary(context),
                    ),
                  const SizedBox(width: 6),
                  Text(
                    'Mark all read',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: disabled
                          ? AppColors.adaptiveTextSecondary(context).withValues(alpha: 0.5)
                          : AppColors.adaptiveTextPrimary(context),
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
