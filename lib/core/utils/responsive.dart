import 'package:flutter/material.dart';

class Responsive {
  static const double mobileBreakpoint = 600;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= mobileBreakpoint;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width > mobileBreakpoint;

  static T value<T>(
    BuildContext context, {
    required T mobile,
    required T tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }
}
