part of 'theme_bloc.dart';

class ThemeState {
  final bool isDark;

  const ThemeState({this.isDark = false});

  ThemeState copyWith({bool? isDark}) =>
      ThemeState(isDark: isDark ?? this.isDark);
}
