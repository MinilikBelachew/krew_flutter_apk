import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/core/utils/toast_service.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';
import 'package:movers/features/home/presentation/bloc/home_bloc.dart';
import 'package:movers/features/home/presentation/bloc/home_event.dart';
import 'package:movers/features/home/presentation/bloc/home_state.dart';

class AvailabilityBottomSheet extends StatefulWidget {
  const AvailabilityBottomSheet({super.key});

  @override
  State<AvailabilityBottomSheet> createState() =>
      _AvailabilityBottomSheetState();
}

class _AvailabilityBottomSheetState extends State<AvailabilityBottomSheet> {
  final List<int> _selectedAssignmentIds = [];
  bool _selectAll = false;
  bool _didSubmit = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (!_didSubmit) return;
        if (state.isConfirmingAvailability) return;

        if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
          ToastService.showError(context, 'Failed to confirm availability');
          _didSubmit = false;
          return;
        }

        ToastService.showSuccess(context, 'Availability confirmed');
        context.read<HomeBloc>().add(const HomeJobsFetched(isRefresh: true));
        _didSubmit = false;
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        final pendingJobs = state.jobs
            .where((job) => job.crewStatus.toUpperCase() == 'PENDING')
            .toList();

        final isLoadingCompletedTab =
            state.activeTab == 3 && state.status == HomeStatus.loading;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardBackground(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Center(
                child: Text(
                  'Confirm your availability.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adaptiveTextPrimary(context),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Date and Select All
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Today',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adaptiveTextPrimary(context),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE, MMM d: yyyy').format(DateTime.now()),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.adaptiveTextSecondary(context),
                        ),
                      ),
                    ],
                  ),
                  if (pendingJobs.isNotEmpty)
                    Row(
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _selectAll,
                            onChanged: (val) {
                              setState(() {
                                _selectAll = val ?? false;
                                if (_selectAll) {
                                  _selectedAssignmentIds.clear();
                                  _selectedAssignmentIds.addAll(
                                    pendingJobs.map((j) => j.crewAssignmentId),
                                  );
                                } else {
                                  _selectedAssignmentIds.clear();
                                }
                              });
                            },
                            activeColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Select all',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.adaptiveTextPrimary(context),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Jobs List
              if (isLoadingCompletedTab)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (pendingJobs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'No pending assignments for today.',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ),
                )
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      children: pendingJobs
                          .map((job) => _buildAvailabilityCard(job))
                          .toList(),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Close',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.adaptiveIndigo(context),
                      ),
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed:
                        (_selectedAssignmentIds.isEmpty ||
                            state.isConfirmingAvailability)
                        ? null
                        : () {
                            _didSubmit = true;
                            for (final id in _selectedAssignmentIds) {
                              context.read<HomeBloc>().add(
                                HomeJobConfirmed(id, 'Confirmed'),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 12,
                      ),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: state.isConfirmingAvailability
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            'Confirm',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvailabilityCard(JobEntity job) {
    bool isChecked = _selectedAssignmentIds.contains(job.crewAssignmentId);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.adaptiveCardBackground(context),
        border: Border.all(
          color: AppColors.adaptiveBorder(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isChecked,
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedAssignmentIds.add(job.crewAssignmentId);
                      } else {
                        _selectedAssignmentIds.remove(job.crewAssignmentId);
                      }
                      // Note: We'd need to check if count matches for _selectAll but it's fine for now
                    });
                  },
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Job ${job.id}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.shopping_bag_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.weight,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.local_shipping_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.truckNumber,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      job.pickupAddress, // We'll use address for name in this view if needed
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.dropoffAddress,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
