import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Comprehensive theme system supporting light and dark modes
/// Following Material Design 3 principles with custom design tokens
class AppTheme {
  AppTheme._(); // Private constructor

  // Light Theme
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: DSColors.brand,
      primaryContainer: DSColors.primary100,
      secondary: DSColors.brandLight,
      surface: DSColors.lightSurface,
      error: DSColors.error,
      onPrimary: DSColors.white,
      onSecondary: DSColors.white,
      onSurface: DSColors.lightOnSurface,
      onError: DSColors.white,
      outline: DSColors.lightBorder,
    ),

    // Typography
    textTheme: TextTheme(
      displayLarge: DSTypography.displayLarge,
      displayMedium: DSTypography.displayMedium,
      displaySmall: DSTypography.displaySmall,
      headlineLarge: DSTypography.headlineLarge,
      headlineMedium: DSTypography.headlineMedium,
      headlineSmall: DSTypography.headlineSmall,
      bodyLarge: DSTypography.bodyLarge,
      bodyMedium: DSTypography.bodyMedium,
      bodySmall: DSTypography.bodySmall,
      labelLarge: DSTypography.labelLarge,
      labelMedium: DSTypography.labelMedium,
      labelSmall: DSTypography.labelSmall,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DSColors.lightBackground,
      foregroundColor: DSColors.lightOnBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: DSTypography.headlineMedium,
      shadowColor: DSColors.transparent,
      surfaceTintColor: DSColors.transparent,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: DSColors.lightSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        side: const BorderSide(color: DSColors.lightBorder),
      ),
      margin: const EdgeInsets.all(DSTokens.spaceS),
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DSColors.brand,
        foregroundColor: DSColors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: DSTokens.spaceL,
          vertical: DSTokens.spaceM,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
        textStyle: DSTypography.button,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: DSColors.lightSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        borderSide: const BorderSide(color: DSColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        borderSide: const BorderSide(color: DSColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        borderSide: const BorderSide(color: DSColors.brand, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceM,
        vertical: DSTokens.spaceM,
      ),
      labelStyle: DSTypography.labelMedium,
      hintStyle: DSTypography.bodyMedium.copyWith(color: DSColors.textTertiary),
    ),

    // Scaffold Background
    scaffoldBackgroundColor: DSColors.lightBackground,

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: DSColors.lightBorder,
      thickness: 1,
      space: 1,
    ),
  );

  // Dark Theme
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: DSColors.primary300,
      primaryContainer: DSColors.primary800,
      secondary: DSColors.primary400,
      surface: DSColors.darkSurface,
      error: DSColors.error,
      onPrimary: DSColors.darkBackground,
      onSecondary: DSColors.darkBackground,
      onSurface: DSColors.darkOnSurface,
      onError: DSColors.white,
      outline: DSColors.darkBorder,
    ),

    // Typography (same as light but with dark colors)
    textTheme: TextTheme(
      displayLarge: DSTypography.displayLarge.copyWith(
        color: DSColors.darkOnBackground,
      ),
      displayMedium: DSTypography.displayMedium.copyWith(
        color: DSColors.darkOnBackground,
      ),
      displaySmall: DSTypography.displaySmall.copyWith(
        color: DSColors.darkOnBackground,
      ),
      headlineLarge: DSTypography.headlineLarge.copyWith(
        color: DSColors.darkOnBackground,
      ),
      headlineMedium: DSTypography.headlineMedium.copyWith(
        color: DSColors.darkOnBackground,
      ),
      headlineSmall: DSTypography.headlineSmall.copyWith(
        color: DSColors.darkOnBackground,
      ),
      bodyLarge: DSTypography.bodyLarge.copyWith(
        color: DSColors.darkOnBackground,
      ),
      bodyMedium: DSTypography.bodyMedium.copyWith(
        color: DSColors.darkOnBackground,
      ),
      bodySmall: DSTypography.bodySmall.copyWith(color: DSColors.darkOnSurface),
      labelLarge: DSTypography.labelLarge.copyWith(
        color: DSColors.darkOnBackground,
      ),
      labelMedium: DSTypography.labelMedium.copyWith(
        color: DSColors.darkOnSurface,
      ),
      labelSmall: DSTypography.labelSmall.copyWith(
        color: DSColors.darkOnSurface,
      ),
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: DSColors.darkBackground,
      foregroundColor: DSColors.darkOnBackground,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: DSTypography.headlineMedium.copyWith(
        color: DSColors.darkOnBackground,
      ),
      shadowColor: DSColors.transparent,
      surfaceTintColor: DSColors.transparent,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: DSColors.darkSurface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        side: const BorderSide(color: DSColors.darkBorder),
      ),
      margin: const EdgeInsets.all(DSTokens.spaceS),
    ),

    // Scaffold Background
    scaffoldBackgroundColor: DSColors.darkBackground,

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: DSColors.darkBorder,
      thickness: 1,
      space: 1,
    ),
  );
}
