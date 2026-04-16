import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:movers/core/config/theme.dart';
import 'package:movers/features/home/domain/entities/job_entity.dart';

class HistoryJobCard extends StatelessWidget {
  final JobEntity job;
  const HistoryJobCard({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/job/${job.rawId}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.adaptiveCardBackground(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.adaptiveBorder(context),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: status badge + job id
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          AppColors.adaptiveSuccess(context).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.adaptiveTextPrimary(context),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  Text(
                    job.id,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.adaptiveTextSecondary(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Pickup
              AddressRow(
                icon: Image.asset(
                  'assets/images/origin.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
                label: job.pickupAddress,
                isBold: true,
              ),

              // Dashed connector
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Column(
                  children: List.generate(
                    3,
                    (_) => Container(
                      width: 2,
                      height: 4,
                      margin: const EdgeInsets.symmetric(vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.adaptiveBorder(context),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                ),
              ),

              // Dropoff
              AddressRow(
                icon: Image.asset(
                  'assets/images/destination.png',
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
                label: job.dropoffAddress,
                isBold: false,
              ),

              if (job.status == 'COMPLETED' && job.currentEmployeeDuration != null && job.currentEmployeeDuration!.isNotEmpty) ...[
                const SizedBox(height: 14),
                if (job.currentEmployeeClockIn != null) ...[
                  AddressRow(
                    icon: const Icon(Icons.login_rounded, size: 18, color: Colors.grey),
                    label: 'Clock in: ${DateFormat('hh:mm a').format(job.currentEmployeeClockIn!)}',
                    isBold: false,
                  ),
                  const SizedBox(height: 8),
                ],
                AddressRow(
                  icon: const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                  label: 'My Duration: ${job.currentEmployeeDuration}',
                  isBold: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AddressRow extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isBold;

  const AddressRow({
    super.key,
    required this.icon,
    required this.label,
    required this.isBold,
  });

  @override
  Widget build(BuildContext ctx) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: icon,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isBold
                  ? AppColors.adaptiveTextPrimary(ctx)
                  : AppColors.adaptiveTextSecondary(ctx),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
