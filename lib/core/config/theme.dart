import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFFF470B);
  static const Color secondary = Color(0xFF111827);
  static const Color background = Colors.white;
  static const Color pageBackground = Colors.white;
  static const Color surface = Color(
    0xFFFFFCFA,
  ); // Slightly lighter tint for surface
  static const Color error = Color(0xFFEF4444); // red-500

  static const Color textPrimary = Color(0xFF111827); // gray-900
  static const Color textSecondary = Color(0xFF6B7280); // gray-500
  static const Color border = Color(0xFFE5E7EB); // gray-200

  // ---------- Dark palette ----------
  static const Color darkBackground = Color(0xFF171717);
  static const Color darkPageBackground = Color(0xFF171717);
  static const Color darkSurface = Color(0xFF1B1B1B);
  static const Color darkCardBackground = Color(0xFF302F2D);
  static const Color darkTextPrimary = Color(0xFFE7EAF0);
  static const Color darkTextSecondary = Color(0xFFA6AAB4);
  static const Color darkBorder = Color(0xFF2A2A2A);

  static List<BoxShadow> get lowEmphasisShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.05),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get highEmphasisShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ---------- Adaptive helpers (pick light or dark based on current theme) ----------
  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color adaptiveBackground(BuildContext context) =>
      _isDark(context) ? darkBackground : background;

  static Color adaptivePageBackground(BuildContext context) =>
      _isDark(context) ? darkPageBackground : pageBackground;

  static Color adaptiveSurface(BuildContext context) =>
      _isDark(context) ? darkSurface : surface;

  static Color adaptiveCardBackground(BuildContext context) =>
      _isDark(context) ? darkCardBackground : const Color(0xFFF5F4F2);

  static Color adaptiveTextPrimary(BuildContext context) =>
      _isDark(context) ? darkTextPrimary : textPrimary;

  static Color adaptiveTextSecondary(BuildContext context) =>
      _isDark(context) ? darkTextSecondary : textSecondary;

  static Color adaptiveBorder(BuildContext context) =>
      _isDark(context) ? darkBorder : border;

  static Color skeletonBase(BuildContext context) =>
      _isDark(context) ? const Color(0xFF2A2A2A) : const Color(0xFFE5E7EB);

  static Color skeletonHighlight(BuildContext context) =>
      _isDark(context) ? const Color(0xFF374151) : const Color(0xFFF3F4F6);

  static Color adaptiveNeutralBackground(BuildContext context) =>
      _isDark(context) ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);

  static Color adaptiveMoversBlue(BuildContext context) =>
      _isDark(context) ? const Color(0xFF60A5FA) : const Color(0xFF134E8E);

  static Color adaptiveIndigo(BuildContext context) =>
      _isDark(context) ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);

  static Color adaptiveError(BuildContext context) =>
      _isDark(context) ? const Color(0xFFF87171) : const Color(0xFFEF4444);

  static Color adaptiveSuccess(BuildContext context) =>
      _isDark(context) ? const Color(0xFF4ADE80) : const Color(0xFF16A34A);

  static Color adaptiveWarning(BuildContext context) =>
      _isDark(context) ? const Color(0xFFFBBF24) : const Color(0xFFF59E0B);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.surface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.textPrimary,
      ),
      fontFamily: 'Inter',
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(color: AppColors.textSecondary, size: 24);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x33FF470B),
        selectionHandleColor: AppColors.primary,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.darkSurface,
        surface: AppColors.darkSurface,
        error: AppColors.error,
        onPrimary: Colors.white,
        onSecondary: AppColors.darkTextPrimary,
        onSurface: AppColors.darkTextPrimary,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardColor: AppColors.darkCardBackground,
      dividerColor: AppColors.darkBorder,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.darkTextSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary, size: 24);
          }
          return const IconThemeData(
            color: AppColors.darkTextSecondary,
            size: 24,
          );
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: Color(0x33FF470B),
        selectionHandleColor: AppColors.primary,
      ),
    );
  }
}
