import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Responsive utility class for handling different screen sizes
/// Implements mobile-first responsive design principles
class DSResponsive {
  DSResponsive._(); // Private constructor

  /// Custom breakpoint untuk mobile (default 576px)
  /// Bisa disesuaikan untuk kebutuhan spesifik
  static double customMobileBreakpoint = DSTokens.breakpointS;

  /// Check if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < customMobileBreakpoint;
  }

  /// Check if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= customMobileBreakpoint && width < DSTokens.breakpointL;
  }

  /// Check if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= DSTokens.breakpointL;
  }

  /// Get current screen size info for debugging
  static String getScreenSizeInfo(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final width = size.width;
    final height = size.height;

    String type = isMobile(context)
        ? 'Mobile'
        : isTablet(context)
        ? 'Tablet'
        : 'Desktop';

    return '$type (${width.toInt()}x${height.toInt()}px)';
  }

  /// Set custom mobile breakpoint
  /// Berguna untuk menyesuaikan dengan kebutuhan spesifik app
  static void setMobileBreakpoint(double breakpoint) {
    customMobileBreakpoint = breakpoint;
  }

  /// Get responsive value based on screen size
  static T responsive<T>({
    required BuildContext context,
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) return desktop;
    if (isTablet(context) && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive padding
  static EdgeInsets responsivePadding(BuildContext context) {
    return EdgeInsets.all(
      responsive(
        context: context,
        mobile: DSTokens.spaceM,
        tablet: DSTokens.spaceL,
        desktop: DSTokens.spaceXL,
      ),
    );
  }

  /// Get responsive margin
  static EdgeInsets responsiveMargin(BuildContext context) {
    return EdgeInsets.all(
      responsive(
        context: context,
        mobile: DSTokens.spaceS,
        tablet: DSTokens.spaceM,
        desktop: DSTokens.spaceL,
      ),
    );
  }

  /// Get responsive columns for grid layouts
  static int responsiveColumns(BuildContext context) {
    return responsive(context: context, mobile: 1, tablet: 2, desktop: 3);
  }

  /// Get responsive max width for content containers
  static double responsiveMaxWidth(BuildContext context) {
    return responsive(
      context: context,
      mobile: double.infinity,
      tablet: DSTokens.breakpointM,
      desktop: DSTokens.breakpointL,
    );
  }
}

/// Extension on BuildContext for easier responsive access
extension DSResponsiveExtension on BuildContext {
  bool get isMobile => DSResponsive.isMobile(this);
  bool get isTablet => DSResponsive.isTablet(this);
  bool get isDesktop => DSResponsive.isDesktop(this);

  /// Get current screen info for debugging
  String get screenInfo => DSResponsive.getScreenSizeInfo(this);

  /// Get current screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get current screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  T responsive<T>({required T mobile, T? tablet, T? desktop}) =>
      DSResponsive.responsive(
        context: this,
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );
}
