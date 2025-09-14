import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../tokens/colors.dart';
import '../providers/theme_provider.dart';

/// Theme-aware color helper
/// Provides colors that automatically adapt to light/dark mode
class ThemeColors {
  ThemeColors._();

  /// Get surface color based on current theme
  static Color surface(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkSurface : DSColors.lightSurface;
  }

  /// Get background color based on current theme
  static Color background(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkBackground : DSColors.lightBackground;
  }

  /// Get primary text color based on current theme
  static Color textPrimary(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkOnSurface : DSColors.textPrimary;
  }

  /// Get secondary text color based on current theme
  static Color textSecondary(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark
        ? DSColors.textSecondary.withValues(alpha: 0.7)
        : DSColors.textSecondary;
  }

  /// Get tertiary text color based on current theme
  static Color textTertiary(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark
        ? DSColors.textTertiary.withValues(alpha: 0.6)
        : DSColors.textTertiary;
  }

  /// Get border color based on current theme
  static Color border(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkBorder : DSColors.lightBorder;
  }

  /// Get elevated surface color based on current theme
  static Color surfaceElevated(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkSurfaceElevated : DSColors.surfaceElevated;
  }

  /// Get container color based on current theme
  static Color surfaceContainer(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkSurfaceElevated : DSColors.surfaceContainer;
  }

  /// Get shadow color based on current theme (darker for dark mode)
  static Color shadowColor(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark
        ? DSColors.black.withValues(alpha: 0.3)
        : DSColors.black.withValues(alpha: 0.1);
  }

  /// Get card color based on current theme
  static Color cardColor(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.darkSurface : DSColors.lightSurface;
  }

  /// Get on-color text (for colored backgrounds)
  static Color textOnColor(WidgetRef ref) {
    return DSColors.textOnColor; // Always white, works on both themes
  }

  /// Get inverse text color
  static Color textInverse(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    return isDark ? DSColors.textPrimary : DSColors.textInverse;
  }
}

/// Extension to easily get theme-aware colors
extension ThemeColorsExtension on WidgetRef {
  /// Quick access to theme colors
  ThemeAwareColors get colors => ThemeAwareColors(this);
}

/// Theme-aware colors instance
class ThemeAwareColors {
  final WidgetRef _ref;

  ThemeAwareColors(this._ref);

  Color get surface => ThemeColors.surface(_ref);
  Color get background => ThemeColors.background(_ref);
  Color get textPrimary => ThemeColors.textPrimary(_ref);
  Color get textSecondary => ThemeColors.textSecondary(_ref);
  Color get textTertiary => ThemeColors.textTertiary(_ref);
  Color get border => ThemeColors.border(_ref);
  Color get surfaceElevated => ThemeColors.surfaceElevated(_ref);
  Color get surfaceContainer => ThemeColors.surfaceContainer(_ref);
  Color get shadowColor => ThemeColors.shadowColor(_ref);
  Color get cardColor => ThemeColors.cardColor(_ref);
  Color get textOnColor => ThemeColors.textOnColor(_ref);
  Color get textInverse => ThemeColors.textInverse(_ref);
}
