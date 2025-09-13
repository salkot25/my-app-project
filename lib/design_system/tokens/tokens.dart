import 'package:flutter/material.dart';

/// Minimalist Modern Design Tokens
/// Clean, spacious design following modern UI principles
/// Inspired by professional login screen aesthetics
class DSTokens {
  DSTokens._(); // Private constructor to prevent instantiation

  // Modern Spacing Scale - Generous for clean look
  static const double spaceXXS = 2;
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;
  static const double spaceXXL = 48;
  static const double spaceXXXL = 64;

  // Clean Border Radius - Modern rounded corners
  static const double radiusXS = 4;
  static const double radiusS = 8;
  static const double radiusM = 12; // Main radius for inputs/buttons
  static const double radiusL = 16;
  static const double radiusXL = 20; // Large cards like login form
  static const double radiusXXL = 24;
  static const double radiusCircle = 999;

  // Modern Typography Scale
  static const double fontXS = 12;
  static const double fontS = 14;
  static const double fontM = 16;
  static const double fontL = 18;
  static const double fontXL = 20;
  static const double fontXXL = 24;
  static const double fontXXXL = 32; // Welcome Back
  static const double fontDisplay = 48;

  // Clean Line Heights
  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.5;
  static const double lineHeightLoose = 1.8;

  // Modern Font Weights
  static const FontWeight fontWeightLight = FontWeight.w300;
  static const FontWeight fontWeightRegular = FontWeight.w400;
  static const FontWeight fontWeightMedium = FontWeight.w500;
  static const FontWeight fontWeightSemiBold = FontWeight.w600;
  static const FontWeight fontWeightBold = FontWeight.w700;

  // Subtle Modern Shadows - Clean and minimal
  static const BoxShadow shadowXS = BoxShadow(
    color: Color(0x05000000), // Very subtle
    blurRadius: 2,
    offset: Offset(0, 1),
  );

  static const BoxShadow shadowS = BoxShadow(
    color: Color(0x0A000000), // Card shadow like login form
    blurRadius: 20, // Softer blur
    offset: Offset(0, 4),
  );

  static const BoxShadow shadowM = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 25,
    offset: Offset(0, 8),
  );

  static const BoxShadow shadowL = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 30,
    offset: Offset(0, 12),
  );

  // Responsive Breakpoints
  static const double breakpointXS = 320;
  static const double breakpointS = 576;
  static const double breakpointM = 768;
  static const double breakpointL = 1024;
  static const double breakpointXL = 1440;

  // Smooth Modern Animations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);

  // Z-index levels
  static const int zIndexDropdown = 1000;
  static const int zIndexModal = 2000;
  static const int zIndexTooltip = 3000;
}
