import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';

/// Minimalist Modern Typography System
/// Clean, readable fonts with modern spacing and weights
/// Inspired by professional login screen design
class DSTypography {
  DSTypography._(); // Private constructor

  // Modern Font Families - Clean and Professional
  static const String fontFamilyPrimary = 'Inter'; // Clean, modern
  static const String fontFamilySecondary = 'SF Pro Display'; // Apple-like
  static const String fontFamilyMono = 'JetBrains Mono'; // Technical

  // Modern Display Styles - Clean Headlines

  static TextStyle displayHero = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: 64,
    fontWeight: DSTokens.fontWeightBold,
    height: 1.1,
    letterSpacing: -2.0,
    color: DSColors.textPrimary,
  );

  static TextStyle displayLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontDisplay,
    fontWeight: DSTokens.fontWeightBold,
    height: DSTokens.lineHeightTight,
    letterSpacing: -1.0,
    color: DSColors.textPrimary,
  );

  // Welcome Back style - from login screen
  static TextStyle displayMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXXXL, // 32px
    fontWeight: DSTokens.fontWeightBold, // w700
    height: DSTokens.lineHeightTight,
    letterSpacing: -1.0, // Negative spacing like login
    color: DSColors.textPrimary,
  );

  static TextStyle displaySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXXL,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: DSTokens.lineHeightTight,
    letterSpacing: -0.5,
    color: DSColors.textPrimary,
  );

  // Clean Headline Styles
  static TextStyle headlineXL = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontXXL,
    fontWeight: DSTokens.fontWeightSemiBold,
    height: 1.3,
    letterSpacing: -0.5,
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

  // Clean Body Text - Modern and Readable
  static TextStyle bodyXL = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontL,
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.6,
    color: DSColors.textPrimary,
  );

  static TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM, // 16px
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.6,
    color: DSColors.textPrimary,
  );

  // "Sign in to your account" subtitle style
  static TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontM, // 16px like login subtitle
    fontWeight: DSTokens.fontWeightRegular,
    height: 1.5,
    letterSpacing: 0.1, // Slight spacing like login
    color: DSColors.textSecondary, // #64748B
  );

  static TextStyle bodySmall = TextStyle(
    fontFamily: fontFamilyPrimary,
    fontSize: DSTokens.fontS, // 14px
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
