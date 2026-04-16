import 'package:flutter/material.dart';
import 'package:movers/core/config/theme.dart';

class SettingsSkeleton extends StatefulWidget {
  const SettingsSkeleton({super.key});

  @override
  State<SettingsSkeleton> createState() => _SettingsSkeletonState();
}

class _SettingsSkeletonState extends State<SettingsSkeleton>
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final base = Color.lerp(
          isDarkMode ? const Color(0xFF262626) : Colors.grey[300],
          isDarkMode ? const Color(0xFF333333) : Colors.grey[100],
          _controller.value,
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
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Avatar circle
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(color: base, shape: BoxShape.circle),
              ),
              const SizedBox(height: 24),
              // Name/Phone box
              box(w: 180, h: 22, r: 8),
              const SizedBox(height: 10),
              // Role box
              box(w: 100, h: 14, r: 6),
              const SizedBox(height: 48),
              // Section label stub
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: box(w: 80, h: 12, r: 4),
                ),
              ),
              const SizedBox(height: 12),
              // Grouped items card stub
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveCardBackground(context),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    box(w: double.infinity, h: 20, r: 8),
                    const SizedBox(height: 20),
                    box(w: double.infinity, h: 20, r: 8),
                    const SizedBox(height: 20),
                    box(w: double.infinity, h: 20, r: 8),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Another section label
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: box(w: 80, h: 12, r: 4),
                ),
              ),
              const SizedBox(height: 12),
              box(w: double.infinity, h: 64, r: 22),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
