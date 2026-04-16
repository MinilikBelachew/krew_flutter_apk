import 'dart:convert';
import 'package:flutter/foundation.dart';

class LoggerUtils {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  static void logJson(String name, dynamic data) {
    if (kDebugMode) {
      try {
        final String prettyJson = _encoder.convert(data);
        debugPrint('================= $name =================');
        debugPrint(prettyJson);
        debugPrint('================================================');
      } catch (e) {
        debugPrint('Error logging JSON ($name): $e');
        debugPrint('Raw data: $data');
      }
    }
  }
}
