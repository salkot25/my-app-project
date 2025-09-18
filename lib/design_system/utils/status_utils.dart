import 'package:flutter/material.dart';
import '../../domain/entities/user_status.dart';
import '../design_system.dart';

/// Utility class for user status styling and functionality
/// Provides consistent colors, icons, and utilities for different user statuses across the application
class StatusUtils {
  StatusUtils._(); // Private constructor

  /// Get the color associated with a specific user status
  ///
  /// Returns:
  /// - Verified: Success color (green) - indicates verified account
  /// - Unverified: Warning color (orange) - indicates pending verification
  /// - Suspended: Error color (red) - indicates suspended account
  static Color getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return DSColors.success;
      case UserStatus.unverified:
        return DSColors.warning;
      case UserStatus.suspended:
        return DSColors.error;
    }
  }

  /// Get the icon associated with a specific user status
  ///
  /// Returns:
  /// - Verified: Check circle icon - indicates verified status
  /// - Unverified: Pending icon - indicates waiting for verification
  /// - Suspended: Block icon - indicates suspended account
  static IconData getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return Icons.check_circle_rounded;
      case UserStatus.unverified:
        return Icons.pending_rounded;
      case UserStatus.suspended:
        return Icons.block_rounded;
    }
  }

  /// Get a lighter variant of the status color with custom alpha
  static Color getStatusColorWithAlpha(UserStatus status, double alpha) {
    return getStatusColor(status).withValues(alpha: alpha);
  }

  /// Get status color variants for different states
  static Color getStatusColorLight(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return DSColors.successLight;
      case UserStatus.unverified:
        return DSColors.warningLight;
      case UserStatus.suspended:
        return DSColors.errorLight;
    }
  }

  /// Get dark variant of status colors for better contrast in dark themes
  static Color getStatusColorDark(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return DSColors.successDark;
      case UserStatus.unverified:
        return DSColors.warningDark;
      case UserStatus.suspended:
        return DSColors.errorDark;
    }
  }

  /// Get status name as string for display purposes
  static String getStatusName(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return 'Verified';
      case UserStatus.unverified:
        return 'Unverified';
      case UserStatus.suspended:
        return 'Suspended';
    }
  }

  /// Get status description for UI display
  static String getStatusDescription(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return 'Account is verified and fully active';
      case UserStatus.unverified:
        return 'Account pending verification';
      case UserStatus.suspended:
        return 'Account access has been suspended';
    }
  }

  /// Get status actions available for the status
  static List<String> getStatusActions(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return [
          'Account can access all features',
          'Full community participation',
          'Can create and share content',
          'Eligible for premium features',
        ];
      case UserStatus.unverified:
        return [
          'Limited account features',
          'Email verification required',
          'Some features may be restricted',
          'Complete verification to unlock full access',
        ];
      case UserStatus.suspended:
        return [
          'Account access temporarily restricted',
          'Contact administrator for resolution',
          'Review community guidelines',
          'Appeal process available',
        ];
    }
  }

  /// Check if status allows full access
  static bool isActiveStatus(UserStatus status) {
    return status == UserStatus.verified;
  }

  /// Check if status requires attention
  static bool requiresAttention(UserStatus status) {
    return status != UserStatus.verified;
  }

  /// Get status priority level (higher number = more critical)
  static int getStatusPriority(UserStatus status) {
    switch (status) {
      case UserStatus.suspended:
        return 3; // Critical - needs immediate attention
      case UserStatus.unverified:
        return 2; // Warning - needs verification
      case UserStatus.verified:
        return 1; // Normal - all good
    }
  }

  /// Get appropriate text color for status badges (usually white for dark backgrounds)
  static Color getStatusTextColor(UserStatus status) {
    // For status badges with colored backgrounds, white text usually works best
    return DSColors.white;
  }
}
