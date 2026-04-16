import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/theme.dart';
import '../../domain/entities/job_entity.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../logic/home_ui_utils.dart';
import 'meta_chip.dart';
import 'dashed_line_painter.dart';

class JobCard extends StatelessWidget {
  final JobEntity job;
  final bool isConfirmingAvailability;
  final bool isSelectionMode;
  final bool isSelected;
  final VoidCallback? onLongPress;
  final VoidCallback? onToggleSelected;

  const JobCard({
    super.key,
    required this.job,
    required this.isConfirmingAvailability,
    this.isSelectionMode = false,
    this.isSelected = false,
    this.onLongPress,
    this.onToggleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final (statusBgColor, statusTextColor) = HomeUIUtils.getStatusColors(
      context,
      job.status,
    );
    final needsConfirmation = HomeUIUtils.jobNeedsConfirmation(job);
    final isConfirming = isConfirmingAvailability;

    final cardBorderColor = isSelectionMode
        ? (isSelected ? AppColors.primary : AppColors.adaptiveBorder(context))
        : AppColors.adaptiveBorder(context);

    final cardBgColor = isSelectionMode
        ? (isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : AppColors.adaptiveCardBackground(context))
        : AppColors.adaptiveCardBackground(context);

    return InkWell(
      onTap: () {
        if (isSelectionMode) {
          // Already in selection mode — toggle this card
          onToggleSelected?.call();
        } else if (needsConfirmation) {
          // First tap on a confirmable job enters selection mode
          onLongPress?.call();
        } else {
          // Normal job — navigate to details
          context.push('/job/${job.rawId}');
        }
      },
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cardBorderColor),
          image: DecorationImage(
            image: AssetImage(
              isDarkMode
                  ? 'assets/images/map_darkmode.png'
                  : 'assets/images/map.jpg',
            ),
            fit: BoxFit.cover,
            opacity: 0.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (needsConfirmation)
                    InkWell(
                      onTap: isConfirming
                          ? null
                          : () {
                              if (isSelectionMode) {
                                onToggleSelected?.call();
                              } else {
                                onLongPress?.call();
                              }
                            },
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        width: 22,
                        height: 22,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.adaptiveBorder(context),
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 13,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveNeutralBackground(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      job.id,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveTextSecondary(context),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      HomeUIUtils.formatStatus(job.status),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: statusTextColor,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.adaptiveBorder(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.adaptiveNeutralBackground(
                              context,
                            ).withValues(alpha: isDarkMode ? 0.4 : 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/origin.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: CustomPaint(
                              size: const Size(2, double.infinity),
                              painter: DashedLinePainter(
                                color: AppColors.adaptiveBorder(context),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: AppColors.adaptiveNeutralBackground(
                              context,
                            ).withValues(alpha: isDarkMode ? 0.4 : 0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            'assets/images/destination.png',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ORIGIN',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.adaptiveTextSecondary(
                                    context,
                                  ),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.pickupAddress,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.adaptiveTextPrimary(context),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DESTINATION',
                                style: GoogleFonts.inter(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.adaptiveTextSecondary(
                                    context,
                                  ),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                job.dropoffAddress,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.adaptiveTextPrimary(context),
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.adaptiveBorder(
                    context,
                  ).withValues(alpha: 0.6),
                ),
              ),
              Row(
                children: [
                  MetaChip(icon: Icons.inventory_2_outlined, label: job.weight),
                  const SizedBox(width: 8),
                  MetaChip(
                    icon: Icons.local_shipping_outlined,
                    label: job.truckNumber,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CrewAvatars(
                    job: job,
                    isSelectionMode: isSelectionMode,
                    onToggleSelected: onToggleSelected,
                  ),
                  _JobActions(
                    job: job,
                    needsConfirmation: needsConfirmation,
                    isConfirming: isConfirming,
                    isSelectionMode: isSelectionMode,
                    onToggleSelected: onToggleSelected,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CrewAvatars extends StatelessWidget {
  final JobEntity job;
  final bool isSelectionMode;
  final VoidCallback? onToggleSelected;

  const _CrewAvatars({
    required this.job,
    required this.isSelectionMode,
    this.onToggleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          onToggleSelected?.call();
          return;
        }
        // Use a placeholder or a global method if needed, or pass callback
      },
      child: SizedBox(
        width: 100,
        height: 32,
        child: Stack(
          children: [
            _buildCrewAvatar(context, 0, job, 0),
            if (job.crewCount > 1) _buildCrewAvatar(context, 20, job, 1),
            if (job.crewCount > 2)
              _buildMoreIndicator(context, 40, '+${job.crewCount - 2}'),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewAvatar(
    BuildContext context,
    double left,
    JobEntity job,
    int index,
  ) {
    final String? photoUrl = index < job.crewMembers.length
        ? job.crewMembers[index].photoUrl
        : null;
    final String? resolvedPhotoUrl = _resolvePhotoUrl(photoUrl);

    return Positioned(
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.adaptiveCardBackground(context),
            width: 2,
          ),
        ),
        child: CircleAvatar(
          radius: 16,
          backgroundImage: resolvedPhotoUrl != null
              ? NetworkImage(resolvedPhotoUrl)
              : null,
          backgroundColor: AppColors.surface,
          child: resolvedPhotoUrl == null
              ? Icon(
                  Icons.person,
                  size: 18,
                  color: AppColors.adaptiveTextSecondary(context),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildMoreIndicator(BuildContext context, double left, String text) {
    return Positioned(
      left: left,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.adaptiveNeutralBackground(context),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.adaptiveCardBackground(context),
            width: 2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.adaptiveTextSecondary(context),
          ),
        ),
      ),
    );
  }

  String? _resolvePhotoUrl(String? photoUrl) {
    if (photoUrl == null) return null;
    final trimmed = photoUrl.trim();
    if (trimmed.isEmpty) return null;
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://'))
      return trimmed;
    if (trimmed.startsWith('/'))
      return 'https://movers-backend.learnica.net$trimmed';
    return trimmed;
  }
}

class _JobActions extends StatelessWidget {
  final JobEntity job;
  final bool needsConfirmation;
  final bool isConfirming;
  final bool isSelectionMode;
  final VoidCallback? onToggleSelected;

  const _JobActions({
    required this.job,
    required this.needsConfirmation,
    required this.isConfirming,
    required this.isSelectionMode,
    this.onToggleSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (needsConfirmation) ...[
          ElevatedButton(
            onPressed: isConfirming
                ? null
                : () {
                    context.read<HomeBloc>().add(
                      HomeJobConfirmed(job.crewAssignmentId, 'CONFIRMED'),
                    );
                  },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              minimumSize: const Size(0, 38),
              backgroundColor: isDarkMode
                  ? AppColors.adaptiveNeutralBackground(context)
                  : const Color(
                      0xFFE2E8F0,
                    ), // Medium-light Slate for light mode
              foregroundColor: isDarkMode
                  ? Colors.white
                  : const Color(0xFF1E293B), // Dark Slate text for light mode
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: isConfirming
                ? SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDarkMode
                          ? Colors.white
                          : const Color(0xFF1E293B),
                    ),
                  )
                : Text(
                    'Confirm',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
        SizedBox(
          height: 38,
          width: 38,
          child: OutlinedButton(
            onPressed: () {
              if (isSelectionMode) {
                onToggleSelected?.call();
                return;
              }
              context.push('/job/${job.rawId}');
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: AppColors.adaptiveTextPrimary(context),
              side: BorderSide(color: AppColors.adaptiveBorder(context)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Icon(Icons.arrow_forward_rounded, size: 18),
          ),
        ),
      ],
    );
  }
}
