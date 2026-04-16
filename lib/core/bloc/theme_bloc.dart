import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'theme_event.dart';
part 'theme_state.dart';

const _kDarkModeKey = 'dark_mode';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final FlutterSecureStorage _storage;

  ThemeBloc({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      super(const ThemeState()) {
    on<ThemeLoadRequested>(_onLoad);
    on<ThemeToggleRequested>(_onToggle);
  }

  Future<void> _onLoad(
    ThemeLoadRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final value = await _storage.read(key: _kDarkModeKey);
    emit(state.copyWith(isDark: value == 'true'));
  }

  Future<void> _onToggle(
    ThemeToggleRequested event,
    Emitter<ThemeState> emit,
  ) async {
    final newValue = !state.isDark;
    await _storage.write(key: _kDarkModeKey, value: newValue.toString());
    emit(state.copyWith(isDark: newValue));
  }
}
