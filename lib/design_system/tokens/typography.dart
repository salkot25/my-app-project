import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';

/// Enhanced typography system with accessibility and brand voice
/// Supporting multiple font families and text styles
class DSTypography {
  DSTypography._(); // Private constructor

  // Font Families - Brand Typography Stack
  static const String fontFamilyPrimary = 'Inter'; // Clean, modern, readable
  static const String fontFamilySecondary = 'Poppins'; // Friendly, approachable
  static const String fontFamilyMono =
      'JetBrains Mono'; // Code, technical content

  // Enhanced Text Styles with Brand Voice

  // Display Styles - Hero content
  static TextStyle displayHero = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 64,
    fontWeight: DSTokens.fontWeightBold,
    height: 1.1,
    letterSpacing: -1.5,
    color: DSColors.textPrimary,
  );

  static TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontDisplay,
    fontWeight: DSTokens.fontWeightBold,
    height: DSTokens.lineHeightTight,
    letterSpacing: -0.5,
    color: DSColors.textPrimary,
  );

  static TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXXXL,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: DSTokens.lineHeightTight,
    letterSpacing: -0.25,
    color: DSColors.textPrimary,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXXL,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: DSTokens.lineHeightTight,
    letterSpacing: -0.25,
    color: DSColors.textPrimary,
  );

  // Headline Styles - Section headers
  static TextStyle headlineXL = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: DSTokens.fontXXL,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: 1.3,
    letterSpacing: -0.25,
    color: DSColors.textPrimary,
  );

  static TextStyle headlineLarge = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: DSTokens.fontXL,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: 1.4,
    color: DSColors.textPrimary,
  );

  static TextStyle headlineMedium = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: DSTokens.fontL,
    fontWeight: DSTokens.fontWeightMedium,
    height: 1.4,
    color: DSColors.textPrimary,
  );

  static TextStyle headlineSmall = TextStyle(
    fontFamily: fontFamilySecondary,
    fontSize: DSTokens.fontM,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: DSTokens.lineHeightNormal,
    color: DSColors.textPrimary,
  );

  // Body Styles - Reading content
  static TextStyle bodyXL = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontL,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.6, // Improved readability
    color: DSColors.textPrimary,
  );

  static TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.6,
    color: DSColors.textPrimary,
  );

  static TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontS,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.5,
    color: DSColors.textSecondary,
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXS,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.4,
    color: DSColors.textTertiary,
  );

  // Label Text Styles - Enhanced
  static TextStyle labelLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM,
    fontWeight: DSTokens.fontWeightMedium,
    height: DSTokens.lineHeightNormal,
    color: DSColors.textPrimary,
    letterSpacing: 0.1,
  );

  static TextStyle labelMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontS,
    fontWeight: DSTokens.fontWeightMedium,
    height: DSTokens.lineHeightNormal,
    color: DSColors.textSecondary,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXS,
    fontWeight: DSTokens.fontWeightMedium,
    height: DSTokens.lineHeightNormal,
    color: DSColors.textTertiary,
    letterSpacing: 0.5,
  );

  // Interactive Styles
  static TextStyle buttonLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: 1.0,
    letterSpacing: 0.5,
    color: DSColors.textOnColor,
  );

  static TextStyle buttonMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontS,
    fontWeight: DSTokens.fontWeightMedium,
    height: 1.0,
    letterSpacing: 0.25,
    color: DSColors.textOnColor,
  );

  static TextStyle button = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM,
    fontWeight: DSTokens.fontWeightMedium,
    height: DSTokens.lineHeightNormal,
    letterSpacing: 0.5,
  );

  static TextStyle link = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM,
    fontWeight: DSTokens.fontWeightMedium,
    height: 1.5,
    color: DSColors.textLink,
    decoration: TextDecoration.underline,
    decorationColor: DSColors.textLink,
  );

  // Utility Styles
  static TextStyle code = TextStyle(
    fontFamily: fontFamilyMono,
    fontSize: DSTokens.fontS,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.4,
    color: DSColors.textSecondary,
    backgroundColor: DSColors.surfaceContainer,
  );

  static TextStyle caption = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXS,
    fontWeight: DSTokens.fontWeightRegular,
    height: DSTokens.lineHeightNormal,
    color: DSColors.textTertiary,
  );

  static TextStyle overline = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXS,
    fontWeight: DSTokens.fontWeightMedium,
    height: 1.0,
    letterSpacing: 1.5,
    color: DSColors.textTertiary,
  );

  // Error/Success text styles
  static TextStyle error = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXS,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.4,
    color: DSColors.error,
  );

  static TextStyle success = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXS,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.4,
    color: DSColors.success,
  );

  // Accessibility helper
  static TextStyle withAccessibleContrast(TextStyle style, Color background) {
    if (DSColors.isAccessibleContrast(
      style.color ?? DSColors.textPrimary,
      background,
    )) {
      return style;
    }
    // Return high contrast version
    return style.copyWith(
      color: background.computeLuminance() > 0.5
          ? DSColors.textPrimary
          : DSColors.textOnColor,
    );
  }
}
