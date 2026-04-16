import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';

class BottomSheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BottomSheetTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.adaptiveNeutralBackground(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child:
            Icon(icon, size: 18, color: AppColors.adaptiveTextPrimary(context)),
      ),
      title: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.adaptiveTextPrimary(context),
        ),
      ),
      onTap: onTap,
    );
  }
}
