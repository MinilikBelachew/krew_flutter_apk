import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';
import 'package:movers/features/job_details/presentation/widgets/time_summary_card.dart';

class JobResourcesCard extends StatelessWidget {
  final JobDetailEntity job;

  const JobResourcesCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('EEEE, MMM d').format(job.scheduledDate);
    final timeRange =
        (job.startTime != null && job.startTime!.isNotEmpty) ||
            (job.endTime != null && job.endTime!.isNotEmpty)
        ? '${job.startTime ?? ''}${(job.startTime != null && job.startTime!.isNotEmpty) && (job.endTime != null && job.endTime!.isNotEmpty) ? ' - ' : ''}${job.endTime ?? ''}'
        : '';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.adaptiveTextPrimary(context).withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Resources',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptiveTextPrimary(context),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.adaptiveSurface(context),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '#${job.id}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.adaptiveTextSecondary(context),
                  ),
                ),
              ),
            ],
          ),
          if (timeRange.isNotEmpty) ...[
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                timeRange,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.shopping_bag_outlined,
                size: 14,
                color: AppColors.adaptiveTextSecondary(context),
              ),
              const SizedBox(width: 4),
              Text(
                job.weight,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.local_shipping_outlined,
                size: 14,
                color: AppColors.adaptiveTextSecondary(context),
              ),
              const SizedBox(width: 4),
              Text(
                job.truckNumber,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.adaptiveTextSecondary(context),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          buildResourceRow(
            context,
            'Crew',
            '${job.ballparkCrewSize ?? job.crewCount}',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 8),
          if (job.currentStatus == 'Completed' &&
              job.duration != null &&
              job.duration!.isNotEmpty) ...[
            const SizedBox(height: 8),
            buildResourceRow(context, 'Duration', job.duration!),
          ],
        ],
      ),
    );
  }
}

