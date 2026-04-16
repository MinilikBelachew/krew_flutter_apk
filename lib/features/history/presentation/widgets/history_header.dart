import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:movers/core/config/theme.dart';

class HistoryHeader extends StatelessWidget {
  const HistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.adaptiveTextPrimary(context),
                  size: 26,
                ),
                padding: const EdgeInsets.only(right: 12),
                constraints: const BoxConstraints(),
              ),
              Text(
                'History',
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.adaptiveTextPrimary(context),
                  letterSpacing: -0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your completed jobs',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
