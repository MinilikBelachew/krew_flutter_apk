part of 'theme_bloc.dart';

abstract class ThemeEvent {}

/// Dispatched on app startup to load the persisted theme preference.
class ThemeLoadRequested extends ThemeEvent {}

/// Dispatched when the user taps the dark mode toggle.
class ThemeToggleRequested extends ThemeEvent {}
