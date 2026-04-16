import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/theme.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';
import '../widgets/home_dashboard_section.dart';
import '../widgets/home_header_pill.dart';
import '../widgets/job_card.dart';
import '../widgets/skeleton_job_card.dart';
import '../../../../features/settings/presentation/widgets/settings_drawer.dart';
import '../../../../core/utils/toast_service.dart';
import '../../../../core/services/local_notifications_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Request permissions upon entering the home page slightly delayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 600), () {
        LocalNotificationsService.instance.requestPermissions();
      });
    });
    context.read<HomeBloc>().add(const HomeJobsFetched());
    _startPolling();
  }

  @override
  void dispose() {
    _stopPolling();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        context.read<HomeBloc>().add(const HomeJobsFetched(isRefresh: true));
      }
    });
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
  }

  void _onScroll() {
    // Determine if we are near the bottom of the scroll view
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<HomeBloc>().add(HomeLoadMoreJobs());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) =>
          curr.errorMessage != null && curr.errorMessage != prev.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ToastService.showError(context, state.errorMessage!);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.adaptiveBackground(context),
        drawer: const SettingsDrawer(),
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(
                const HomeJobsFetched(isRefresh: true),
              );
            },
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 1. Search Header (Scrolls away)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  sliver: SliverToBoxAdapter(
                    child: HomeHeaderPill(
                      searchController: _searchController,
                      onSearchChanged: (val) {
                        context.read<HomeBloc>().add(
                          HomeSearchQueryChanged(val),
                        );
                      },
                      hasUnreadNotifications: true,
                      onNotificationTap: () => context.push('/notifications'),
                    ),
                  ),
                ),

                // 2. Sticky Dashboard Cards (Pinned)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverHeaderDelegate(
                    height: 206.0,
                    theme: Theme.of(context),
                    child: const HomeDashboardSection(),
                  ),
                ),

                // 3. Job list
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.status == HomeStatus.initial ||
                        (state.status == HomeStatus.loading &&
                            state.jobs.isEmpty)) {
                      return SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) => const Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: SkeletonJobCard(),
                            ),
                            childCount: 4,
                          ),
                        ),
                      );
                    }

                    if (state.status == HomeStatus.failure &&
                        state.jobs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.6,
                          child: _buildErrorState(
                            state.errorMessage ?? 'Connection error',
                          ),
                        ),
                      );
                    }

                    if (state.jobs.isEmpty) {
                      return SliverToBoxAdapter(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: _buildEmptyState(),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final job = state.jobs[index];
                          final isThisCardConfirming =
                              state.confirmingAssignmentId ==
                              job.crewAssignmentId;

                          return JobCard(
                            job: job,
                            isConfirmingAvailability: isThisCardConfirming,
                            isSelectionMode: state.isSelectionMode,
                            isSelected: state.selectedCrewAssignmentIds
                                .contains(job.crewAssignmentId),
                            onLongPress: () {
                              context.read<HomeBloc>().add(
                                HomeSelectionModeEnabled(job.crewAssignmentId),
                              );
                            },
                            onToggleSelected: () {
                              context.read<HomeBloc>().add(
                                HomeSelectionToggled(job.crewAssignmentId),
                              );
                            },
                          );
                        }, childCount: state.jobs.length),
                      ),
                    );
                  },
                ),

                // Loading indicator for infinite scroll
                BlocBuilder<HomeBloc, HomeState>(
                  builder: (context, state) {
                    if (state.isFetchingMore) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),

                // Bottom spacing for safety
                const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _SelectionBottomBar(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: AppColors.adaptiveTextSecondary(
              context,
            ).withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            'No jobs found',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.adaptiveTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or search',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.cloud_off_outlined,
              size: 48,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Could not connect',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.adaptiveTextPrimary(context),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'We couldn\'t load your jobs. Please check your internet connection and try again.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.adaptiveTextSecondary(context),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.read<HomeBloc>().add(const HomeJobsFetched());
              },
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final ThemeData theme;
  final Widget child;

  _SliverHeaderDelegate({
    required this.height,
    required this.theme,
    required this.child,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(
      child: Container(
        color: AppColors.adaptiveBackground(context),
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return oldDelegate.height != height ||
        oldDelegate.child != child ||
        oldDelegate.theme != theme;
  }
}

class _SelectionBottomBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (!state.isSelectionMode) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.fromLTRB(
            16,
            8,
            16,
            8 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardBackground(context),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                '${state.selectedCrewAssignmentIds.length} selected',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adaptiveTextPrimary(context),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  context.read<HomeBloc>().add(const HomeSelectionCleared());
                },
                style: TextButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('Cancel', style: GoogleFonts.inter(fontSize: 13)),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: state.selectedCrewAssignmentIds.isEmpty
                    ? null
                    : () {
                        context.read<HomeBloc>().add(
                          const HomeBulkConfirmRequested('CONFIRMED'),
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: const StadiumBorder(),
                  elevation: 0,
                ),
                child: state.isConfirmingAvailability
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Confirm All',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
