import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/config/theme.dart';

class TodayHeroCard extends StatelessWidget {
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLoading;

  const TodayHeroCard({
    super.key,
    required this.count,
    this.isSelected = false,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final primaryColor =
        isDarkMode ? const Color(0xFF1E293B) : const Color(0xFF64748B);
    final primaryDark =
        isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF475569);
    final primaryLight =
        isDarkMode ? const Color(0xFF334155) : const Color(0xFF94A3B8);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [primaryDark, primaryColor, primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withValues(alpha: 0.3)
                  : primaryColor.withValues(alpha: isSelected ? 0.35 : 0.2),
              blurRadius: isSelected ? 24 : 14,
              spreadRadius: isSelected ? 1 : 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // ── Background decorative bubbles ──
              Positioned(
                right: -28,
                top: -28,
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.10),
                  ),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -40,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.07),
                  ),
                ),
              ),
              Positioned(
                left: -16,
                bottom: -20,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.06),
                  ),
                ),
              ),
              Positioned(
                right: 90,
                top: 10,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Positioned(
                right: 130,
                bottom: 14,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                ),
              ),

              // ── Content ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    // Calendar icon with frosted pill background
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/images/calender.png',
                          width: 34,
                          height: 34,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Text column
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Jobs",
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withValues(alpha: 0.85),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: SkeletonDashboardBox(
                                        width: 24,
                                        height: 24,
                                        baseColor: Colors.white.withValues(alpha: 0.2),
                                        highlightColor: Colors.white.withValues(alpha: 0.4),
                                      ),
                                    )
                                  : Text(
                                      '$count',
                                      style: GoogleFonts.inter(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                        height: 1.0,
                                      ),
                                    ),
                              const SizedBox(width: 8),
                              Text(
                                count == 1 ? 'job assigned' : 'jobs assigned',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.75),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Selected shimmer overlay ──
              if (isSelected)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecondaryDashboardCard extends StatelessWidget {
  final String assetPath;
  final String title;
  final String value;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isLoading;

  const SecondaryDashboardCard({
    super.key,
    required this.assetPath,
    required this.title,
    required this.value,
    required this.accentColor,
    this.isSelected = false,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDarkMode ? 0.15 : 0.15)
              : AppColors.adaptiveCardBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: isDarkMode ? 0.9 : 0.7)
                : AppColors.adaptiveBorder(context).withValues(alpha: isDarkMode ? 0.2 : 0.4),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.1,
                        color: isSelected
                            ? accentColor
                            : AppColors.adaptiveTextSecondary(context),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            isLoading
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: SkeletonDashboardBox(
                      width: 20,
                      height: 20,
                      baseColor: AppColors.skeletonBase(context),
                      highlightColor: AppColors.skeletonHighlight(context),
                    ),
                  )
                : Text(
                    value,
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppColors.adaptiveTextPrimary(context),
                      height: 1.0,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class HomeDashboardSection extends StatelessWidget {
  const HomeDashboardSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final counts = state.statusCounts;
        final isLoading = state.status == HomeStatus.initial ||
            (state.status == HomeStatus.loading && state.jobs.isEmpty);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              TodayHeroCard(
                count: counts.today,
                isLoading: isLoading,
                isSelected: state.activeTab == 1,
                onTap: () =>
                    context.read<HomeBloc>().add(const HomeTabChanged(1)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SecondaryDashboardCard(
                      assetPath: 'assets/images/all.png',
                      title: 'All',
                      value: '${counts.all}',
                      isLoading: isLoading,
                      accentColor: const Color(0xFF475569),
                      isSelected: state.activeTab == 0,
                      onTap: () =>
                          context.read<HomeBloc>().add(const HomeTabChanged(0)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SecondaryDashboardCard(
                      assetPath: 'assets/images/upcomming.png',
                      title: 'Upcoming',
                      value: '${counts.upcoming}',
                      isLoading: isLoading,
                      accentColor: const Color(0xFF475569),
                      isSelected: state.activeTab == 2,
                      onTap: () =>
                          context.read<HomeBloc>().add(const HomeTabChanged(2)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SecondaryDashboardCard(
                      assetPath: 'assets/images/done.png',
                      title: 'Done',
                      value: '${counts.completed}',
                      isLoading: isLoading,
                      accentColor: const Color(0xFF475569),
                      isSelected: state.activeTab == 3,
                      onTap: () =>
                          context.read<HomeBloc>().add(const HomeTabChanged(3)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class SkeletonDashboardBox extends StatefulWidget {
  final double width;
  final double height;
  final Color baseColor;
  final Color highlightColor;

  const SkeletonDashboardBox({
    super.key,
    required this.width,
    required this.height,
    required this.baseColor,
    required this.highlightColor,
  });

  @override
  State<SkeletonDashboardBox> createState() => _SkeletonDashboardBoxState();
}

class _SkeletonDashboardBoxState extends State<SkeletonDashboardBox>
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
        final color = Color.lerp(widget.baseColor, widget.highlightColor, t)!;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
    );
  }
}

