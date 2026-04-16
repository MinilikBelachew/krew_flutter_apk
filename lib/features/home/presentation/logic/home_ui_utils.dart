import 'package:flutter/material.dart';
import '../../../../core/config/theme.dart';
import '../../domain/entities/job_entity.dart';

class HomeUIUtils {
  static (Color, Color) getStatusColors(BuildContext context, String status) {
    switch (status.toUpperCase()) {
      case 'SCHEDULED':
        return (
          const Color(0xFF3B82F6).withValues(alpha: 0.1),
          const Color(0xFF3B82F6)
        );
      case 'EN_ROUTE_TO_PICKUP':
      case 'AT_PICKUP':
        return (
          const Color(0xFFF59E0B).withValues(alpha: 0.1),
          const Color(0xFFF59E0B)
        );
      case 'LOADING':
      case 'EN_ROUTE_TO_DELIVERY':
      case 'AT_DELIVERY':
      case 'UNLOADING':
        return (
          AppColors.primary.withValues(alpha: 0.1),
          AppColors.primary
        );
      case 'COMPLETED':
        return (
          const Color(0xFF10B981).withValues(alpha: 0.1),
          const Color(0xFF10B981)
        );
      default:
        return (
          AppColors.adaptiveNeutralBackground(context),
          AppColors.adaptiveTextSecondary(context)
        );
    }
  }

  static String formatStatus(String status) {
    const statusMap = {
      'EN_ROUTE_TO_PICKUP': 'En Route to Pickup',
      'AT_PICKUP': 'At Pickup',
      'LOADING': 'Loading',
      'EN_ROUTE_TO_DELIVERY': 'En Route to Delivery',
      'AT_DELIVERY': 'At Delivery',
      'UNLOADING': 'Unloading',
      'COMPLETED': 'Completed',
      'SCHEDULED': 'Scheduled',
    };

    if (statusMap.containsKey(status.toUpperCase())) {
      return statusMap[status.toUpperCase()]!;
    }

    return status
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map((word) => word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  static bool jobNeedsConfirmation(JobEntity job) {
    return job.crewStatus.toUpperCase() != 'CONFIRMED';
  }
}
