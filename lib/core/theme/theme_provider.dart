import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kThemeModeKey = 'theme_mode';

/// Manages the app-wide ThemeMode with SharedPreferences persistence.
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_kThemeModeKey);
    if (stored == 'dark') {
      state = ThemeMode.dark;
    } else if (stored == 'light') {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.system;
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    // Cycle: system → light → dark → light …
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
      await prefs.setString(_kThemeModeKey, 'light');
    } else {
      state = ThemeMode.dark;
      await prefs.setString(_kThemeModeKey, 'dark');
    }
  }
}

/// Global provider for the current ThemeMode.
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);
