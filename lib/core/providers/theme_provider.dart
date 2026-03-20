import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Extended theme modes including AMOLED.
enum AppThemeMode {
  light,
  dark,
  system,
  amoled;

  String get label => switch (this) {
        light => 'Light',
        dark => 'Dark',
        system => 'System',
        amoled => 'AMOLED',
      };

  ThemeMode get themeMode => switch (this) {
        light => ThemeMode.light,
        dark => ThemeMode.dark,
        system => ThemeMode.system,
        amoled => ThemeMode.dark,
      };

  static AppThemeMode fromString(String value) => switch (value) {
        'light' => light,
        'dark' => dark,
        'amoled' => amoled,
        _ => system,
      };
}

/// Notifier that persists theme preference to SharedPreferences.
class ThemeNotifier extends Notifier<AppThemeMode> {
  static const _key = 'theme_mode';

  @override
  AppThemeMode build() {
    _load();
    return AppThemeMode.system;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored != null) {
      state = AppThemeMode.fromString(stored);
    }
  }

  Future<void> setTheme(AppThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}

final themeProvider =
    NotifierProvider<ThemeNotifier, AppThemeMode>(ThemeNotifier.new);
