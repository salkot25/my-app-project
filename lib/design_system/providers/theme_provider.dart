import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode enumeration
enum AppThemeMode {
  light,
  dark,
  system;

  /// Get the corresponding Flutter ThemeMode
  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Get display name for the theme mode
  String get displayName {
    switch (this) {
      case AppThemeMode.light:
        return 'Light Mode';
      case AppThemeMode.dark:
        return 'Dark Mode';
      case AppThemeMode.system:
        return 'System';
    }
  }

  /// Get icon for the theme mode
  IconData get icon {
    switch (this) {
      case AppThemeMode.light:
        return Icons.light_mode_rounded;
      case AppThemeMode.dark:
        return Icons.dark_mode_rounded;
      case AppThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  /// Convert from string
  static AppThemeMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'system':
      default:
        return AppThemeMode.system;
    }
  }
}

/// Theme notifier class
class ThemeNotifier extends AsyncNotifier<AppThemeMode> {
  static const String _themeKey = 'theme_mode';

  @override
  Future<AppThemeMode> build() async {
    return await _loadThemeMode();
  }

  /// Load theme mode from SharedPreferences
  Future<AppThemeMode> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey) ?? 'system';
      return AppThemeMode.fromString(themeModeString);
    } catch (e) {
      // If there's an error loading, default to system theme
      debugPrint('Error loading theme mode: $e');
      return AppThemeMode.system;
    }
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, themeMode.name);
    } catch (e) {
      // Handle error silently - theme will still work for current session
      debugPrint('Error saving theme mode: $e');
    }
  }

  /// Set theme mode
  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final currentTheme = await future;
    if (currentTheme == themeMode) return;

    state = AsyncValue.data(themeMode);
    await _saveThemeMode(themeMode);
  }

  /// Toggle between light and dark mode (skips system)
  Future<void> toggleTheme() async {
    final currentTheme = await future;
    final newTheme = currentTheme == AppThemeMode.light
        ? AppThemeMode.dark
        : AppThemeMode.light;
    await setThemeMode(newTheme);
  }

  /// Cycle through all theme modes
  Future<void> cycleThemeMode() async {
    final currentTheme = await future;
    final modes = AppThemeMode.values;
    final currentIndex = modes.indexOf(currentTheme);
    final nextIndex = (currentIndex + 1) % modes.length;
    await setThemeMode(modes[nextIndex]);
  }
}

/// Theme provider
final themeProvider = AsyncNotifierProvider<ThemeNotifier, AppThemeMode>(() {
  return ThemeNotifier();
});

/// Convenience providers
final themeModeProvider = Provider<AppThemeMode>((ref) {
  final asyncTheme = ref.watch(themeProvider);
  return asyncTheme.when(
    data: (themeMode) => themeMode,
    loading: () => AppThemeMode.system,
    error: (_, _) => AppThemeMode.system,
  );
});

final flutterThemeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(themeModeProvider).themeMode;
});

final isThemeLoadingProvider = Provider<bool>((ref) {
  return ref.watch(themeProvider).isLoading;
});

/// Check if current theme is dark mode
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  if (themeMode == AppThemeMode.dark) return true;
  if (themeMode == AppThemeMode.light) return false;

  // For system mode, check the platform brightness
  final brightness =
      WidgetsBinding.instance.platformDispatcher.platformBrightness;
  return brightness == Brightness.dark;
});
