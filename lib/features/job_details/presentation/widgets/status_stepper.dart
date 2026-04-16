import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movers/core/config/theme.dart';

class StatusStepper extends StatelessWidget {
  final String currentStatus;
  final DateTime? clockIn;
  final DateTime? clockOut;
  final Map<String, DateTime>? statusTimestamps;

  const StatusStepper({
    super.key,
    required this.currentStatus,
    this.clockIn,
    this.clockOut,
    this.statusTimestamps,
  });

  final List<String> statuses = const [
    'En route',
    'Arrived',
    'Loading',
    'Loaded',
    'Delivery',
    'Unload',
    'Completed',
    'Arrived at HQ',
  ];

  @override
  Widget build(BuildContext context) {
    final String displayStatus = currentStatus;
    final Color accent = AppColors.primary;

    String labelFor(String status) {
      return {
            'Arrived at HQ': 'Arrived HQ',
            'En route': 'Left HQ',
            'Arrived': 'Arrived Pickup',
            'Loading': 'Loading',
            'Loaded': 'Left for Delivery',
            'Delivery': 'Arrived Delivery',
            'Unload': 'Unloading',
            'Completed': 'Completed',
          }[status] ??
          status;
    }

    String fmt(DateTime? dt) {
      if (dt == null) return '--';
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    }

    String timestampFor(String status) {
      if (status == statuses.first) return fmt(clockIn);
      if (status == 'Completed') return fmt(clockOut);

      final local = statusTimestamps?[status];
      if (local != null) return fmt(local);
      return '--';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final innerAvailable = constraints.maxWidth - 32; // padding 16*2
        final computedPerStepWidth = (innerAvailable / statuses.length).clamp(
          54.0,
          double.infinity,
        );
        final contentWidth = computedPerStepWidth * statuses.length;
        final needsScroll =
            contentWidth > (innerAvailable + 1.0); // +1 for rounding
        final perStepWidth = needsScroll
            ? 70.0
            : (innerAvailable / statuses.length);
        final effectiveContentWidth = perStepWidth * statuses.length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.adaptiveCardBackground(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.adaptiveBorder(context)),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: effectiveContentWidth < innerAvailable
                    ? innerAvailable
                    : effectiveContentWidth,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(statuses.length, (index) {
                  final status = statuses[index];
                  final bool isCompleted = _isCompleted(status, displayStatus);
                  final bool isCurrent = status == displayStatus;

                  final dot = Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isCompleted || isCurrent
                          ? accent.withValues(alpha: 0.1)
                          : AppColors.adaptiveNeutralBackground(context),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted || isCurrent
                            ? accent
                            : AppColors.adaptiveTextSecondary(
                                context,
                              ).withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: isCompleted
                        ? Icon(Icons.check, size: 14, color: accent)
                        : Center(
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: isCurrent ? accent : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                  );

                  final leftLine = (index == 0)
                      ? const Expanded(child: SizedBox())
                      : Expanded(
                          child: Container(
                            height: 2,
                            color: _segmentActive(index - 1, displayStatus)
                                ? accent
                                : AppColors.adaptiveBorder(context),
                          ),
                        );

                  final rightLine = (index == statuses.length - 1)
                      ? const Expanded(child: SizedBox())
                      : Expanded(
                          child: Container(
                            height: 2,
                            color: _segmentActive(index, displayStatus)
                                ? accent
                                : AppColors.adaptiveBorder(context),
                          ),
                        );

                  return SizedBox(
                    width: perStepWidth,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 24,
                          child: Row(children: [leftLine, dot, rightLine]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          labelFor(status),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            height: 1.15,
                            fontWeight: isCurrent
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isCurrent
                                ? AppColors.adaptiveTextPrimary(context)
                                : AppColors.adaptiveTextSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          timestampFor(status),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 9,
                            height: 1.0,
                            fontWeight: FontWeight.w500,
                            color: AppColors.adaptiveTextSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isCompleted(String status, String displayStatus) {
    if (status == 'Arrived at HQ') {
      return statusTimestamps?['Arrived at HQ'] != null;
    }
    if (status == 'Completed') {
      return displayStatus == 'Completed' && clockOut != null;
    }

    final currentIndex = statuses.indexOf(displayStatus);
    final targetIndex = statuses.indexOf(status);

    if (currentIndex == -1) return false;
    return targetIndex < currentIndex;
  }

  bool _segmentActive(int segmentIndex, String displayStatus) {
    final currentIndex = statuses.indexOf(displayStatus);
    if (currentIndex == -1) return false;

    // Arrived at HQ case
    if (segmentIndex == statuses.length - 1) {
      return statusTimestamps?['Arrived at HQ'] != null;
    }

    return segmentIndex < currentIndex;
  }
}
