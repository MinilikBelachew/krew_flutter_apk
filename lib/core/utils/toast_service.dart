import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';
import '../config/theme.dart';

class ToastService {
  static String _parseMessage(dynamic message) {
    if (message == null) return 'An unknown error occurred.';
    String msgStr = message.toString();

    // Check for network connectivity issues
    if (msgStr.toLowerCase().contains('failed host lookup') ||
        msgStr.toLowerCase().contains('socketexception') ||
        msgStr.toLowerCase().contains('connection refused') ||
        msgStr.toLowerCase().contains('network is unreachable') ||
        msgStr.toLowerCase().contains('xmlhttprequest onerror') ||
        msgStr.toLowerCase().contains('xmlhttprequest')) {
      return 'Unable to connect to the server. Please check your internet connection or ensure the server is running.';
    }

    if (msgStr.contains('DioException')) {
      if (msgStr.contains('connection timeout') ||
          msgStr.contains('receive timeout') ||
          msgStr.contains('connection error')) {
        return 'Network error: The server took too long to respond or the connection failed. Please ensure you have an active internet connection.';
      }
      if (msgStr.contains('401') || msgStr.contains('Unauthorized')) {
        return 'Session expired or unauthorized. Please log in again.';
      }
      if (msgStr.contains('403') || msgStr.contains('Forbidden')) {
        return 'You do not have permission to perform this action.';
      }
      if (msgStr.contains('404')) {
        return 'The requested resource could not be found.';
      }
      if (msgStr.contains('500') || msgStr.contains('Internal Server Error')) {
        return 'The server encountered an error. Please try again later.';
      }

      // Extract specific backend error message embedded by interceptor inside [unknown] or [bad response]
      final regex = RegExp(r'DioException \[(.*?)\]: (.*)');
      final match = regex.firstMatch(msgStr);
      if (match != null && match.groupCount >= 2) {
        final innerMsg = match.group(2)!.trim();
        // Ignore verbose technical error dumps
        if (!innerMsg.toLowerCase().contains('httpexception:') && 
            !innerMsg.toLowerCase().contains('socketexception') &&
            !innerMsg.toLowerCase().contains('xmlhttprequest')) {
           return innerMsg;
        } else {
           return 'Unable to connect to the server. Please ensure the server is running and check your connection.';
        }
      }
      return 'A network problem occurred. Please try again.';
    }

    if (msgStr.startsWith('Exception: ')) {
      return msgStr.substring(11).trim();
    }

    return msgStr;
  }

  static void showSuccess(BuildContext context, dynamic message) {
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flatColored,
      description: Text(
        _parseMessage(message),
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      showProgressBar: false,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppColors.highEmphasisShadow,
    );
  }

  static void showError(BuildContext context, dynamic message) {
    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flatColored,
      description: Text(
        _parseMessage(message),
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      showProgressBar: false,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 5),
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppColors.highEmphasisShadow,
    );
  }

  static void showInfo(BuildContext context, dynamic message) {
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.flatColored,
      description: Text(
        _parseMessage(message),
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      showProgressBar: false,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppColors.highEmphasisShadow,
    );
  }

  static void showWarning(BuildContext context, dynamic message) {
    toastification.show(
      context: context,
      type: ToastificationType.warning,
      style: ToastificationStyle.flatColored,
      description: Text(
        _parseMessage(message),
        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
      ),
      showProgressBar: false,
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 4),
      borderRadius: BorderRadius.circular(12),
      boxShadow: AppColors.highEmphasisShadow,
    );
  }
}
