import 'package:flutter/material.dart';

/// Design tokens following atomic design principles
/// Contains all design constants for consistent UI
class DSTokens {
  DSTokens._(); // Private constructor to prevent instantiation

  // Spacing Scale - Based on 4px grid
  static const double spaceXXS = 2;
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;
  static const double spaceXXXL = 64;

  // Border Radius
  static const double radiusXS = 4;
  static const double radiusS = 6;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 24;
  static const double radiusCircle = 999;

  // Typography Scale
  static const double fontXS = 12;
  static const double fontS = 14;
  static const double fontM = 16;
  static const double fontL = 18;
  static const double fontXL = 20;
  static const double fontXXL = 24;
  static const double fontXXXL = 32;
  static const double fontDisplay = 48;

  // Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightLoose = 1.8;

  // Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Shadows
  static const BoxShadow shadowXS = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowS = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowM = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowL = BoxShadow(
    color: Color(0x1A000000),
    blurRadius: 16,
    offset: Offset(0, 8),
  );

  // Breakpoints for responsive design (Updated for better mobile detection)
  static const double breakpointXS = 320; // Small mobile
  static const double breakpointS = 576; // Mobile (up to large phones)
  static const double breakpointM = 768; // Tablet (iPad portrait)
  static const double breakpointL = 1024; // Desktop/Tablet landscape
  static const double breakpointXL = 1440; // Large desktop

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Z-index levels
  static const int zIndexDropdown = 1000;
  static const int zIndexModal = 2000;
  static const int zIndexTooltip = 3000;
}
