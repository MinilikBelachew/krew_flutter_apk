import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:movers/core/config/theme.dart';

class JobHeader extends StatelessWidget {
  final String jobId;
  final String? previousJobId;
  final String? nextJobId;
  final bool? isClockedIn;
  final bool isTogglingClock;
  final String currentStatus;
  final VoidCallback? onClockIn;
  final VoidCallback? onClockOut;

  const JobHeader({
    super.key,
    required this.jobId,
    this.previousJobId,
    this.nextJobId,
    this.isClockedIn,
    this.isTogglingClock = false,
    this.currentStatus = 'Scheduled',
    this.onClockIn,
    this.onClockOut,
  });



  @override
  Widget build(BuildContext context) {
    final navColor = AppColors.adaptiveTextPrimary(context);
    final disabledNavColor = AppColors.adaptiveTextSecondary(context);

    final showClockButton =
        currentStatus != 'Scheduled' && currentStatus != 'Completed' && currentStatus != 'Dropped off' && currentStatus != 'Arrived at HQ' && currentStatus != 'Cancelled';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton.icon(
            onPressed: () => context.go('/'),
            icon: Icon(Icons.arrow_back_ios, size: 16, color: navColor),
            label: Text(
              'Back',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: navColor,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: navColor,
              disabledForegroundColor: disabledNavColor,
            ),
          ),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adaptiveCardBackground(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.adaptiveBorder(context)),
                    ),
                    child: Text(
                      'Job $jobId',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.adaptiveTextPrimary(context),
                      ),
                    ),
                  ),
                  if (showClockButton) ...[
                    const SizedBox(width: 8),
                    _buildClockButton(context),
                  ],
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: nextJobId == null
                ? null
                : () {
                    context.pushReplacement('/job/$nextJobId');
                  },
            label: Text(
              'Next',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: navColor,
              ),
            ),
            icon: Icon(Icons.arrow_forward_ios, size: 16, color: navColor),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: navColor,
              disabledForegroundColor: disabledNavColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockButton(BuildContext context) {
    final isClockedIn = this.isClockedIn ?? false;
    final primaryColor = isClockedIn ? const Color(0xFFEF4444) : const Color(0xFF10B981);
    final label = isClockedIn ? 'Clock Out' : 'Clock In';
    final icon = isClockedIn ? Icons.logout_rounded : Icons.login_rounded;

    return InkWell(
      onTap: isTogglingClock
          ? null
          : (isClockedIn ? onClockOut : onClockIn),
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: primaryColor.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isTogglingClock)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            else
              Icon(icon, size: 14, color: primaryColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: primaryColor,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
