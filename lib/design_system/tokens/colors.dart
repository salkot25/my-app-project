import 'package:flutter/material.dart';

/// Minimalist Modern Color System
/// Inspired by clean, professional login design
/// WCAG AA compliant with modern aesthetics
class DSColors {
  DSColors._(); // Private constructor

  // Modern Brand Colors - Enhanced Clean Blue Palette for Minimalism
  static const Color brandPrimary = Color(0xFF3498DB); // Modern blue
  static const Color brandSecondary = Color(0xFF5DADE2); // Light blue
  static const Color brandAccent = Color(0xFF2E86AB); // Dark blue
  
  // Ultra-minimalist brand additions
  static const Color brandUltraLight = Color(0xFFF0F8FF); // Almost white with hint of blue
  static const Color brandWhisper = Color(0xFFFAFCFF);    // Whisper of brand color

  // Legacy aliases for backward compatibility
  static const Color brand = brandPrimary;
  static const Color brandLight = brandSecondary;
  static const Color brandDark = brandAccent;

  // Brand Color Variants - Modern Blue Scale
  static const Color brandPrimary50 = Color(0xFFF0F8FF);
  static const Color brandPrimary100 = Color(0xFFE1F5FE);
  static const Color brandPrimary200 = Color(0xFFB3E5FC);
  static const Color brandPrimary300 = Color(0xFF81D4FA);
  static const Color brandPrimary400 = Color(0xFF4FC3F7);
  static const Color brandPrimary500 = Color(0xFF3498DB);
  static const Color brandPrimary600 = Color(0xFF2E86AB);
  static const Color brandPrimary700 = Color(0xFF1976D2);
  static const Color brandPrimary800 = Color(0xFF1565C0);
  static const Color brandPrimary900 = Color(0xFF0D47A1);

  // Modern Gray Scale - Professional Neutrals Enhanced for Minimalism
  static const Color primary25 = Color(0xFFFCFCFD);  // Ultra-light for minimal backgrounds
  static const Color primary50 = Color(0xFFF8FAFC); // Background light
  static const Color primary100 = Color(0xFFF1F5F9); // Very light
  static const Color primary200 = Color(0xFFE2E8F0); // Light border
  static const Color primary300 = Color(0xFFCBD5E1); // Medium light
  static const Color primary400 = Color(0xFF94A3B8); // Medium
  static const Color primary500 = Color(0xFF64748B); // Text secondary
  static const Color primary600 = Color(0xFF475569); // Text medium
  static const Color primary700 = Color(0xFF334155); // Text dark
  static const Color primary800 = Color(0xFF1E293B); // Very dark
  static const Color primary900 = Color(0xFF1A202C); // Text primary
  static const Color primary950 = Color(0xFF0F172A); // Ultra-dark for minimalist contrast

  // Modern Semantic Colors
  static const Color success = Color(0xFF10B981); // Modern green
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B); // Modern orange
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444); // Modern red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3498DB); // Same as brand
  static const Color infoLight = Color(0xFFE1F5FE);
  static const Color infoDark = Color(0xFF2E86AB);

  // Modern Interactive States
  static const Color interactive = Color(0xFF3498DB);
  static const Color interactiveHover = Color(0xFF2E86AB);
  static const Color interactivePressed = Color(0xFF1976D2);
  static const Color interactiveDisabled = Color(0xFFE2E8F0);
  static const Color interactiveFocus = Color(0xFF5DADE2);

  // Clean Surface Colors
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFAFBFC);
  static const Color surfaceContainer = Color(0xFFF8FAFC);
  static const Color surfaceContainerHigh = Color(0xFFF1F5F9);

  // Light Theme Colors - Minimalist Clean
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean gray
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white
  static const Color lightOnBackground = Color(0xFF1A202C); // Dark text
  static const Color lightOnSurface = Color(0xFF1A202C); // Dark text
  static const Color lightBorder = Color(0xFFE2E8F0); // Subtle border

  // Dark Theme Colors - Professional Dark
  static const Color darkBackground = Color(0xFF0F172A); // Deep dark
  static const Color darkSurface = Color(0xFF1E293B); // Card surface
  static const Color darkSurfaceElevated = Color(0xFF334155); // Elevated
  static const Color darkOnBackground = Color(0xFFF8FAFC); // Light text
  static const Color darkOnSurface = Color(0xFFE2E8F0); // Light text
  static const Color darkBorder = Color(0xFF475569); // Dark border

  // Modern Text Colors - Optimized for Readability
  static const Color textPrimary = Color(0xFF1A202C); // Very dark
  static const Color textSecondary = Color(0xFF64748B); // Medium gray
  static const Color textTertiary = Color(0xFF94A3B8); // Light gray
  static const Color textDisabled = Color(0xFFCBD5E1); // Very light
  static const Color textOnColor = Color(0xFFFFFFFF); // White on color
  static const Color textLink = Color(0xFF3498DB); // Brand blue
  static const Color textInverse = Color(0xFFF8FAFC); // Light on dark

  // Border & Dividers
  static const Color borderSubtle = Color(0xFFE5E7EB); // Gray 200
  static const Color border = Color(0xFFD1D5DB); // Gray 300
  static const Color borderStrong = Color(0xFF9CA3AF); // Gray 400
  static const Color borderFocus = Color(0xFF6366F1); // Brand Primary

  // Neutral Colors
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);

  // Validation method for contrast ratio
  static bool isAccessibleContrast(Color foreground, Color background) {
    // Simplified contrast calculation - in real app use proper contrast library
    final fgLuminance = foreground.computeLuminance();
    final bgLuminance = background.computeLuminance();
    final contrast = (fgLuminance > bgLuminance)
        ? (fgLuminance + 0.05) / (bgLuminance + 0.05)
        : (bgLuminance + 0.05) / (fgLuminance + 0.05);
    return contrast >= 4.5; // WCAG AA standard
  }
}
