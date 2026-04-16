import 'package:flutter/material.dart';
import 'package:movers/core/config/theme.dart';

class JobDetailsSkeleton extends StatefulWidget {
  const JobDetailsSkeleton({super.key});

  @override
  State<JobDetailsSkeleton> createState() => _JobDetailsSkeletonState();
}

class _JobDetailsSkeletonState extends State<JobDetailsSkeleton>
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 900;
            final maxContentWidth = isWide ? 920.0 : double.infinity;

            Widget header() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  box(w: 36, h: 36, r: 12),
                  const SizedBox(width: 12),
                  Expanded(child: box(h: 36, r: 18)),
                  const SizedBox(width: 12),
                  box(w: 36, h: 36, r: 12),
                ],
              ),
            );

            Widget statusStepper() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: box(w: double.infinity, h: 64, r: 16),
            );

            Widget tabs() => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: box(w: double.infinity, h: 44, r: 22),
            );

            Widget card(double h) => box(w: double.infinity, h: h, r: 16);

            final body = isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            card(110),
                            const SizedBox(height: 16),
                            card(180),
                            const SizedBox(height: 16),
                            card(140),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          children: [
                            card(220),
                            const SizedBox(height: 16),
                            card(160),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      card(96),
                      const SizedBox(height: 16),
                      card(180),
                      const SizedBox(height: 16),
                      card(140),
                    ],
                  );

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      header(),
                      const SizedBox(height: 16),
                      statusStepper(),
                      const SizedBox(height: 16),
                      tabs(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: body,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
