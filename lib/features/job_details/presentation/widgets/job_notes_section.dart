import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';

class JobNotesSection extends StatelessWidget {
  final JobDetailEntity job;

  const JobNotesSection({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Notes',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.adaptiveTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.adaptiveSurface(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.adaptiveBorder(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (job.notes.isEmpty)
                  Text(
                    'No notes provided.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.adaptiveTextSecondary(context),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                else
                  ...job.notes.map(
                    (note) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        note,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.adaptiveTextSecondary(context),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

