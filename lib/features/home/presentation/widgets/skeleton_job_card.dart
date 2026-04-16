import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';

class SkeletonJobCard extends StatefulWidget {
  const SkeletonJobCard({super.key});

  @override
  State<SkeletonJobCard> createState() => _SkeletonJobCardState();
}

class _SkeletonJobCardState extends State<SkeletonJobCard>
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

        Widget box({double? w, required double h, double r = 10}) => Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(r),
          ),
        );

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardBackground(context),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [box(w: 110, h: 14, r: 6), box(w: 48, h: 20, r: 6)],
              ),
              const SizedBox(height: 12),
              box(w: double.infinity, h: 16, r: 8),
              const SizedBox(height: 10),
              box(w: double.infinity, h: 16, r: 8),
              const SizedBox(height: 16),
              Row(
                children: [
                  box(w: 70, h: 14, r: 8),
                  const SizedBox(width: 12),
                  box(w: 70, h: 14, r: 8),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: base,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: base,
                        ),
                      ),
                    ],
                  ),
                  box(w: 90, h: 32, r: 10),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
