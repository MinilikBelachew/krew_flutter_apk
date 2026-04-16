import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';

class NotificationCard extends StatelessWidget {
  final String title;
  final Widget body;
  final String time;
  final bool isUnread;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const NotificationCard({
    super.key,
    required this.title,
    required this.body,
    required this.time,
    required this.isUnread,
    required this.isFavorite,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.adaptiveBorder(context),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.08 : 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon - grayscale/neutral
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.adaptiveNeutralBackground(context),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.notifications_rounded,
                  size: 16,
                  color: AppColors.adaptiveTextSecondary(context)
                      .withValues(alpha: isUnread ? 1.0 : 0.5),
                ),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Expanded(
                          child: Text(
                            title.isEmpty ? 'Notification' : title,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: AppColors.adaptiveTextPrimary(context)
                                  .withValues(alpha: isUnread ? 1.0 : 0.7),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          time,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.adaptiveTextSecondary(context)
                                .withValues(alpha: isUnread ? 0.6 : 0.4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    body,
                  ],
                ),
              ),

              // Right side: Only Favorite
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: onFavorite,
                    child: Icon(
                      isFavorite
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      size: 18,
                      color: isFavorite
                          ? const Color(0xFFF59E0B)
                          : AppColors.adaptiveTextSecondary(context)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
