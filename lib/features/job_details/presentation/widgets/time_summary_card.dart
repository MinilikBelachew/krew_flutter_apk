import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/job_details/domain/entities/job_detail_entity.dart';

Widget buildResourceRow(
  BuildContext context,
  String label,
  String value, {
  IconData? icon,
}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.adaptiveTextSecondary(context),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: AppColors.adaptiveTextSecondary(context),
              ),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.adaptiveTextPrimary(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class TimeSummaryCard extends StatelessWidget {
  final JobDetailEntity job;
  final CrewMember? currentUserCrew;

  const TimeSummaryCard({
    super.key,
    required this.job,
    required this.currentUserCrew,
  });

  @override
  Widget build(BuildContext context) {
    final hasClockTimes =
        (job.clockIn != null) ||
        (job.clockOut != null) ||
        (currentUserCrew?.duration?.isNotEmpty == true) ||
        job.arrivedAtHqAt != null;
    if (job.currentStatus != 'Completed' || !hasClockTimes) {
      return const SizedBox.shrink();
    }

    final clockInStr = job.clockIn != null
        ? DateFormat('hh:mm a').format(job.clockIn!)
        : '--';
    final clockOutStr = job.clockOut != null
        ? DateFormat('hh:mm a').format(job.clockOut!)
        : '--';
    final durationStr = (currentUserCrew?.duration != null && currentUserCrew!.duration!.isNotEmpty)
        ? currentUserCrew!.duration!
        : '--';

    String breakTakenStr = '--';
    if (job.clockIn != null && job.clockOut != null && currentUserCrew?.duration != null) {
      final totalElapsed = job.clockOut!.difference(job.clockIn!);
      final durationRegex = RegExp(r'(?:(\d+)\s*h)?\s*(?:(\d+)\s*m)?');
      final match = durationRegex.firstMatch(currentUserCrew!.duration!);
      int workMins = 0;
      if (match != null) {
        final h = int.tryParse(match.group(1) ?? '0') ?? 0;
        final m = int.tryParse(match.group(2) ?? '0') ?? 0;
        workMins = (h * 60) + m;
      }
      final breakMins = totalElapsed.inMinutes - workMins;
      if (breakMins >= 0) {
        final bh = breakMins ~/ 60;
        final bm = breakMins % 60;
        breakTakenStr = '${bh}h ${bm}m';
      }
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
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
            'Time summary',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.adaptiveTextSecondary(context),
            ),
          ),
          const SizedBox(height: 12),
          buildResourceRow(
            context,
            'Clock in',
            clockInStr,
            icon: Icons.login_rounded,
          ),
          const SizedBox(height: 8),
          buildResourceRow(
            context,
            'Clock out',
            clockOutStr,
            icon: Icons.logout_rounded,
          ),
          const SizedBox(height: 8),
          buildResourceRow(
            context,
            'Time Worked',
            durationStr,
            icon: Icons.timer_outlined,
          ),
          if (breakTakenStr != '--') ...[
            const SizedBox(height: 8),
            buildResourceRow(
              context,
              'Break Time',
              breakTakenStr,
              icon: Icons.coffee_outlined,
            ),
          ],
        ],
      ),
    );
  }
}
