import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/utils/responsive.dart';
import 'package:movers/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_bloc.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_event.dart';
import 'package:movers/features/job_details/presentation/bloc/job_details_state.dart';
import 'package:movers/core/utils/toast_service.dart';
import 'package:movers/features/job_details/presentation/widgets/client_info_card.dart';
import 'package:movers/features/job_details/presentation/widgets/inventory_tab_view.dart';
import 'package:movers/features/job_details/presentation/widgets/packing_tab_view.dart';
import 'package:movers/features/job_details/presentation/widgets/job_header.dart';
import 'package:movers/features/job_details/presentation/widgets/notify_customer_dialog.dart';
import 'package:movers/features/job_details/presentation/widgets/photos_tab_view.dart';
import 'package:movers/features/job_details/presentation/widgets/job_tabs.dart';
import 'package:movers/features/job_details/presentation/widgets/route_details_card.dart';
import 'package:movers/features/job_details/presentation/widgets/status_stepper.dart';
// import 'package:movers/features/job_details/presentation/widgets/job_map_widget.dart';
import 'package:movers/features/job_details/presentation/widgets/start_job_dialog.dart';
import 'package:movers/features/job_details/presentation/widgets/job_details_skeleton.dart';
import 'package:movers/features/job_details/presentation/widgets/time_summary_card.dart';
import 'package:movers/features/job_details/presentation/widgets/job_resources_card.dart';
import 'package:movers/features/job_details/presentation/widgets/job_move_size_card.dart';
import 'package:movers/features/job_details/presentation/widgets/job_notes_section.dart';

import 'package:movers/features/job_details/domain/repositories/job_details_repository.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';
import 'package:movers/features/home/domain/repositories/home_repository.dart';

class JobDetailsPage extends StatefulWidget {
  final String jobId;
  const JobDetailsPage({super.key, required this.jobId});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late Future<List<JobEntity>> _jobsFuture;

  @override
  void initState() {
    super.initState();
    _jobsFuture = context.read<HomeRepository>().getMyJobs(page: 1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          JobDetailsBloc(context.read<JobDetailsRepository>())
            ..add(LoadJobDetails(widget.jobId)),
      child: Scaffold(
        backgroundColor: AppColors.adaptivePageBackground(context),
        body: SafeArea(
          child: BlocConsumer<JobDetailsBloc, JobDetailsState>(
            listener: (context, state) {
              final msg = state.errorMessage;
              if (msg != null && msg.isNotEmpty) {
                ToastService.showError(context, msg);
              }
            },
            builder: (context, state) {
              if (state.job == null) {
                return const JobDetailsSkeleton();
              }

              final job = state.job!;

              final currentUser = context.read<AuthBloc>().state.user;
              String? activeCrewAssignmentId;
              bool activeCrewClockedIn = false;
              CrewMember? currentUserCrew;
              if (currentUser != null) {
                for (final crew in job.crewMembers) {
                  if (crew.userId == currentUser.id.toString()) {
                    activeCrewAssignmentId = crew.assignmentId;
                    activeCrewClockedIn =
                        crew.clockInTime != null && crew.clockOutTime == null;
                    currentUserCrew = crew;
                    break;
                  }
                }
              }

              return FutureBuilder<List<JobEntity>>(
                future: _jobsFuture,
                builder: (context, jobsSnapshot) {
                  if (jobsSnapshot.hasError) {
                    return Column(
                      children: [
                        JobHeader(
                          jobId: job.displayId,
                          previousJobId: null,
                          nextJobId: null,
                          isClockedIn: activeCrewClockedIn,
                          isTogglingClock: state.isTogglingClock,
                          currentStatus: job.currentStatus,
                          onClockIn: () {
                            if (activeCrewAssignmentId != null) {
                              context.read<JobDetailsBloc>().add(
                                ToggleJobClock(
                                  jobId: job.id,
                                  crewAssignmentId: activeCrewAssignmentId,
                                  action: 'clock-in',
                                ),
                              );
                            } else {
                              ToastService.showError(
                                context,
                                'Crew assignment not found for current user',
                              );
                            }
                          },
                          onClockOut: () {
                            if (activeCrewAssignmentId != null) {
                              context.read<JobDetailsBloc>().add(
                                ToggleJobClock(
                                  jobId: job.id,
                                  crewAssignmentId: activeCrewAssignmentId,
                                  action: 'clock-out',
                                ),
                              );
                            } else {
                              ToastService.showError(
                                context,
                                'Crew assignment not found for current user',
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.primary,
                            backgroundColor: AppColors.adaptiveCardBackground(
                              context,
                            ),
                            onRefresh: () async {
                              context.read<JobDetailsBloc>().add(
                                LoadJobDetails(widget.jobId),
                              );
                            },
                            child: _buildScrollableTabContent(context, state, currentUserCrew),
                          ),
                        ),
                      ],
                    );
                  }

                  final sortedJobs =
                      (jobsSnapshot.data ?? <JobEntity>[]).toList()..sort(
                        (a, b) => a.scheduledDate.compareTo(b.scheduledDate),
                      );

                  final currentIndex = sortedJobs.indexWhere(
                    (j) => j.rawId == job.id,
                  );
                  final String? previousJobId = (currentIndex > 0)
                      ? sortedJobs[currentIndex - 1].rawId
                      : null;
                  final String? nextJobId =
                      (currentIndex != -1 &&
                          currentIndex < sortedJobs.length - 1)
                      ? sortedJobs[currentIndex + 1].rawId
                      : null;

                  return Column(
                    children: [
                      JobHeader(
                        jobId: job.displayId,
                        previousJobId: previousJobId,
                        nextJobId: nextJobId,
                        isClockedIn: activeCrewClockedIn,
                        isTogglingClock: state.isTogglingClock,
                        currentStatus: job.currentStatus,
                        onClockIn: () {
                          if (activeCrewAssignmentId != null) {
                            context.read<JobDetailsBloc>().add(
                              ToggleJobClock(
                                jobId: job.id,
                                crewAssignmentId: activeCrewAssignmentId,
                                action: 'clock-in',
                              ),
                            );
                          } else {
                            ToastService.showError(
                              context,
                              'Crew assignment not found for current user',
                            );
                          }
                        },
                        onClockOut: () {
                          if (activeCrewAssignmentId != null) {
                            context.read<JobDetailsBloc>().add(
                              ToggleJobClock(
                                jobId: job.id,
                                crewAssignmentId: activeCrewAssignmentId,
                                action: 'clock-out',
                              ),
                            );
                          } else {
                            ToastService.showError(
                              context,
                              'Crew assignment not found for current user',
                            );
                          }
                        },
                      ),
                      Builder(
                        builder: (context) {
                          final Map<String, DateTime> backendTimestamps = {};

                          DateTime? firstEventTs(String backendStatus) {
                            for (final e in job.statusEvents) {
                              if (e.status == backendStatus) return e.createdAt;
                            }
                            return null;
                          }

                          final enRoute = firstEventTs('EN_ROUTE_TO_PICKUP');
                          if (enRoute != null) {
                            backendTimestamps['En route'] = enRoute;
                          }

                          final arrived = firstEventTs('AT_PICKUP');
                          if (arrived != null) {
                            backendTimestamps['Arrived'] = arrived;
                          }

                          final loading = firstEventTs('LOADING');
                          if (loading != null) {
                            backendTimestamps['Loading'] = loading;
                          }

                          final loaded = firstEventTs('EN_ROUTE_TO_DELIVERY');
                          if (loaded != null) {
                            backendTimestamps['Loaded'] = loaded;
                          }

                          final delivery = firstEventTs('AT_DELIVERY');
                          if (delivery != null) {
                            backendTimestamps['Delivery'] = delivery;
                          }

                          final unload = firstEventTs('UNLOADING');
                          if (unload != null) {
                            backendTimestamps['Unload'] = unload;
                          }

                          if (job.arrivedAtHqAt != null) {
                            backendTimestamps['Arrived at HQ'] =
                                job.arrivedAtHqAt!;
                          }

                          return StatusStepper(
                            currentStatus: job.currentStatus,
                            clockIn: job.clockIn,
                            clockOut: job.clockOut,
                            statusTimestamps: backendTimestamps,
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      JobTabs(
                        activeTab: state.activeTab,
                        onTabChanged: (tab) =>
                            context.read<JobDetailsBloc>().add(ChangeTab(tab)),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RefreshIndicator(
                          color: AppColors.primary,
                          backgroundColor: AppColors.adaptiveCardBackground(
                            context,
                          ),
                          onRefresh: () async {
                            context.read<JobDetailsBloc>().add(
                              LoadJobDetails(widget.jobId),
                            );
                          },
                          child: _buildScrollableTabContent(context, state, currentUserCrew),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: BlocBuilder<JobDetailsBloc, JobDetailsState>(
          builder: (context, state) {
            if (state.job == null) {
              return const SizedBox.shrink();
            }
            final currentStatus = state.job!.currentStatus;

            if (currentStatus == 'Completed') {
              if (state.job!.arrivedAtHqAt != null) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: SizedBox(
                  width: 180,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: state.isUpdatingStatus
                        ? null
                        : () {
                            context.read<JobDetailsBloc>().add(
                              MarkArrivedAtHq(state.job!.id),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.adaptiveTextPrimary(context),
                      disabledBackgroundColor: AppColors.adaptiveTextPrimary(context).withValues(
                        alpha: 0.6,
                      ),
                      foregroundColor: AppColors.adaptiveBackground(context),
                      disabledForegroundColor: AppColors.adaptiveBackground(context),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 44),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Center(
                      child: state.isUpdatingStatus
                          ? SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.adaptiveBackground(context),
                                ),
                              ),
                            )
                          : Text(
                              'Arrived at HQ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: SizedBox(
                width: 180,
                height: 44,
                child: ElevatedButton(
                  onPressed: state.isUpdatingStatus
                      ? null
                      : () async {
                          bool proceed = false;
                          String nextStatus = '';

                          final authState = context.read<AuthBloc>().state;
                          final currentUserId = authState.user?.id.toString();
                          final crew = state.job!.crewMembers
                              .where(
                                (c) => c.userId.toString() == currentUserId,
                              )
                              .toList();
                          final currentUserCrew = crew.isNotEmpty
                              ? crew.first
                              : null;

                          final isConfirmed =
                              currentUserCrew?.status.trim().toLowerCase() ==
                              'confirmed';

                          if (!isConfirmed) {
                            ToastService.showError(
                              context,
                              'Please confirm the job.',
                            );
                            return;
                          }

                          // Clock-in guard: block status changes if not clocked in.
                          // Exception: 'Scheduled → En route' auto-clocks in on backend.
                          final isClockedIn = currentUserCrew?.clockInTime != null && currentUserCrew?.clockOutTime == null;
                          if (!isClockedIn && currentStatus != 'Scheduled') {
                            if (context.mounted) {
                              await showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Clock In Required'),
                                  content: const Text(
                                    'You must be clocked in before updating the job status. Please tap the Clock In button at the top of the screen.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return;
                          }


                          if (currentStatus == 'Scheduled') {
                            final minutes = await showDialog<int>(
                              context: context,
                              builder: (context) =>
                                  const NotifyCustomerDialog(),
                            );

                            if (minutes != null) {
                              proceed = true;
                              nextStatus = 'En route';

                              if (context.mounted) {
                                context.read<JobDetailsBloc>().add(
                                  minutes > 0
                                      ? UpdateStatus(
                                          nextStatus,
                                          etaMinutes: minutes,
                                        )
                                      : UpdateStatus(nextStatus),
                                );
                              }
                              return;
                            }
                          } else if (currentStatus == 'En route') {
                            proceed = true;
                            nextStatus = 'Arrived';
                          } else if (currentStatus == 'Arrived') {
                            // 1. Start Job Dialog
                            final startResult = await showDialog<bool>(
                              context: context,
                              builder: (context) => const StartJobDialog(),
                            );

                            if (startResult == true) {
                              // Proceed straight to Loading without checking the contract
                              proceed = true;
                              nextStatus = 'Loading';

                              if (context.mounted) {
                                context.read<JobDetailsBloc>().add(
                                  UpdateStatus(
                                    nextStatus,
                                    skipContractCheck: true,
                                  ),
                                );
                              }
                              return;
                            }
                          } else if (currentStatus == 'Loading') {
                            proceed = true;
                            // Track how many pickups we have actually completed by using
                            // the frontend-only counter in the state.
                            final pickupCount = state.job!.pickups.length;
                            final completedPickups = state.currentPickupIndex;

                            // If we haven't completed all pickups, loop back to 'En route'
                            nextStatus = completedPickups < pickupCount
                                ? 'En route'
                                : 'Loaded';
                          } else if (currentStatus == 'Loaded') {
                            proceed = true;
                            nextStatus = 'Delivery';
                          } else if (currentStatus == 'Delivery') {
                            proceed = true;
                            nextStatus = 'Unload';
                          } else if (currentStatus == 'Unload') {
                            proceed = true;
                            // Track how many deliveries we have actually completed
                            final deliveryCount = state.job!.deliveries.length;
                            final completedDeliveries =
                                state.currentDeliveryIndex;

                            // If we haven't completed all deliveries, loop back to 'Loaded' (driving)
                            nextStatus = completedDeliveries < deliveryCount
                                ? 'Loaded'
                                : 'Completed';
                          }

                          if (proceed && context.mounted) {
                            context.read<JobDetailsBloc>().add(
                              UpdateStatus(nextStatus),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adaptiveTextPrimary(context),
                    disabledBackgroundColor: AppColors.adaptiveTextPrimary(context).withValues(alpha: 0.6),
                    foregroundColor: AppColors.adaptiveBackground(context),
                    disabledForegroundColor: AppColors.adaptiveBackground(context),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    minimumSize: const Size(0, 44),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Center(
                    child: state.isUpdatingStatus
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.adaptiveBackground(context),
                              ),
                            ),
                          )
                        : Text(
                            {
                                  'Scheduled': 'Left HQ',
                                  'En route': (() {
                                    final c = state.currentPickupIndex;
                                    final t = state.job!.pickups.length;
                                    return t > 1
                                        ? 'Arrived at Pickup ${c + 1}'
                                        : 'Arrived at Pickup';
                                  })(),
                                  'Arrived': 'Start Loading',
                                  'Loading': (() {
                                    final c = state.currentPickupIndex;
                                    final t = state.job!.pickups.length;
                                    return c < t
                                        ? 'To Pickup ${c + 1}'
                                        : 'Left for Delivery';
                                  })(),
                                  'Loaded': (() {
                                    final c = state.currentDeliveryIndex;
                                    final t = state.job!.deliveries.length;
                                    return t > 1
                                        ? 'Arrived at Delivery ${c + 1}'
                                        : 'Arrived at Delivery';
                                  })(),
                                  'Delivery': 'Start Unloading',
                                  'Unload': (() {
                                    final c = state.currentDeliveryIndex;
                                    final t = state.job!.deliveries.length;
                                    return c < t
                                        ? 'To Delivery ${c + 1}'
                                        : 'Heading to HQ';
                                  })(),
                                }[currentStatus] ??
                                currentStatus,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildScrollableTabContent(
    BuildContext context,
    JobDetailsState state,
    CrewMember? currentUserCrew,
  ) {
    final job = state.job!;
    return SingleChildScrollView(
      child: Column(
        children: [
          if (state.activeTab == JobDetailsTab.jobInfo)
            _buildJobInfoContent(context, state, currentUserCrew),
          if (state.activeTab == JobDetailsTab.inventory) ...[
            InventoryTabView(items: job.inventoryItems, jobId: job.id),
            const SizedBox(height: 100),
          ],
          if (state.activeTab == JobDetailsTab.packing) ...[
            PackingTabView(materials: job.materials, jobId: job.id),
            const SizedBox(height: 100),
          ],
          if (state.activeTab == JobDetailsTab.photos) ...[
            PhotosTabView(jobId: job.id),
            const SizedBox(height: 100),
          ],
        ],
      ),
    );
  }

  Widget _buildJobInfoContent(BuildContext context, JobDetailsState state, CrewMember? currentUserCrew) {
    final job = state.job!;
    final isTablet = Responsive.isTablet(context);

    Widget tagsRow() {
      if (job.leadTags.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: job.leadTags
                .map(
                  (t) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: Theme.of(context).brightness == Brightness.dark
                            ? 0.16
                            : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: Theme.of(context).brightness == Brightness.dark
                              ? 0.35
                              : 0.22,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer_outlined,
                          size: 14,
                          color: AppColors.adaptiveTextPrimary(
                            context,
                          ).withValues(alpha: 0.85),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.adaptiveTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }

    if (isTablet) {
      return Column(
        children: [
          tagsRow(),
          if (job.leadTags.isNotEmpty) const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      ClientInfoCard(
                        name: job.clientName,
                        phone: job.phoneNumber,
                        email: job.email,
                      ),
                      const SizedBox(height: 16),
                      JobResourcesCard(job: state.job!),
                      const SizedBox(height: 16),
                      TimeSummaryCard(job: job, currentUserCrew: currentUserCrew),
                      if (job.currentStatus == 'Completed' &&
                          (job.clockIn != null ||
                              job.clockOut != null ||
                              (currentUserCrew?.duration?.isNotEmpty == true)))
                        const SizedBox(height: 16),
                      JobMoveSizeCard(job: state.job!),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      RouteDetailsCard(
                        pickups: job.pickups,
                        deliveries: job.deliveries,
                        distance: job.distance,
                        onOpenMap: () => context.read<JobDetailsBloc>().add(
                          const ToggleMap(),
                        ),
                      ),
                      if (state.showMap) ...[
                        const SizedBox(height: 16),
                        // JobMapWidget(
                        //   pickups: job.pickups,
                        //   deliveries: job.deliveries,
                        // ),
                      ],
                      const SizedBox(height: 16),
                      JobNotesSection(job: state.job!),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Mobile stacked layout
    return Column(
      children: [
        tagsRow(),
        if (job.leadTags.isNotEmpty) const SizedBox(height: 16),
        ClientInfoCard(
          name: job.clientName,
          phone: job.phoneNumber,
          email: job.email,
        ),
        const SizedBox(height: 16),
        RouteDetailsCard(
          pickups: job.pickups,
          deliveries: job.deliveries,
          distance: job.distance,
          onOpenMap: () =>
              context.read<JobDetailsBloc>().add(const ToggleMap()),
        ),
        if (state.showMap) ...[
          const SizedBox(height: 16),
          // JobMapWidget(pickups: job.pickups, deliveries: job.deliveries),
        ],
        const SizedBox(height: 16),
        JobResourcesCard(job: job),
        const SizedBox(height: 16),
        TimeSummaryCard(job: job, currentUserCrew: currentUserCrew),
        if (job.currentStatus == 'Completed' &&
            (job.clockIn != null ||
                job.clockOut != null ||
                (job.duration?.isNotEmpty == true)))
          const SizedBox(height: 16),
        JobMoveSizeCard(job: job),
        const SizedBox(height: 16),
        JobNotesSection(job: job),
        const SizedBox(height: 100),
      ],
    );
  }

}
