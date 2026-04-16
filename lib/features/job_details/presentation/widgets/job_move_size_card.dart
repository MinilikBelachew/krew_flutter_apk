import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';
import 'package:movers/features/job_details/presentation/widgets/time_summary_card.dart';

class JobMoveSizeCard extends StatelessWidget {
  final JobDetailEntity job;

  const JobMoveSizeCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    if (job.moveSizeName == null &&
        job.moveSizeCubicFt == null &&
        job.moveSizeWeight == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.adaptiveCardBackground(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.005),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Move size',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          if (job.moveSizeName != null)
            buildResourceRow(
              context,
              'Move size',
              job.moveSizeName!,
              icon: Icons.bed_outlined,
            ),
          if (job.moveSizeName != null &&
              (job.moveSizeCubicFt != null || job.moveSizeWeight != null))
            const SizedBox(height: 8),
          if (job.moveSizeCubicFt != null)
            buildResourceRow(context, 'Cubic ft', '${job.moveSizeCubicFt}'),
          if (job.moveSizeCubicFt != null && job.moveSizeWeight != null)
            const SizedBox(height: 8),
          if (job.moveSizeWeight != null)
            buildResourceRow(context, 'Weight', '${job.moveSizeWeight}'),
        ],
      ),
    );
  }
}
