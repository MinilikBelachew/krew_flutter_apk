import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';

/// A reusable pill-style tab bar used across the app.
/// Used on the Home page (Today/Upcoming/Completed) and
/// Job Details page (Job Info/Inventory/Photos).
class PrimaryTabBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  /// If true, tabs are equally spaced and fill the full width (like Job Details).
  /// If false, tabs are scrollable and sized to their content (like Home page).
  final bool expanded;

  const PrimaryTabBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onTabChanged,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    if (expanded) {
      return _buildExpandedTabs(context);
    }
    return _buildScrollableTabs(context);
  }

  /// Scrollable pill chips — used on the Home page.
  Widget _buildScrollableTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool isActive = index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index == labels.length - 1 ? 0 : 12,
            ),
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.adaptiveTextPrimary(context)
                      : AppColors.adaptiveCardBackground(context),
                  borderRadius: BorderRadius.circular(30),
                  border: isActive
                      ? null
                      : Border.all(color: AppColors.adaptiveBorder(context)),
                ),
                child: Text(
                  labels[index],
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.adaptiveBackground(context)
                        : AppColors.adaptiveTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// Expanded equal-width tabs inside a pill container — used on Job Details.
  Widget _buildExpandedTabs(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.adaptiveBorder(context)),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final bool isActive = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.adaptiveTextPrimary(context)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isActive
                        ? AppColors.adaptiveBackground(context)
                        : AppColors.adaptiveTextSecondary(context),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
