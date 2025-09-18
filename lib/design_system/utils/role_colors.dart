import 'package:flutter/material.dart';
import '../../domain/entities/user_role.dart';
import '../design_system.dart';

/// Utility class for role-based styling and functionality
/// Provides consistent colors, icons, and utilities for different user roles across the application
class RoleColors {
  RoleColors._(); // Private constructor

  /// Get the color associated with a specific user role
  ///
  /// Returns:
  /// - Admin: Error color (red) - indicates high authority
  /// - Moderator: Brand primary color (blue) - indicates trust
  /// - User: Success color (green) - indicates standard user
  static Color getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.error; // Consistent with design system
      case UserRole.moderator:
        return DSColors.brandPrimary; // Consistent with design system
      case UserRole.user:
        return DSColors.success; // Consistent with design system
    }
  }

  /// Get the icon associated with a specific user role
  ///
  /// Returns:
  /// - Admin: Admin panel settings icon - indicates system control
  /// - Moderator: Verified user icon - indicates trust and moderation
  /// - User: Person icon - indicates standard user
  static IconData getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.moderator:
        return Icons.verified_user_rounded;
      case UserRole.user:
        return Icons.person_rounded;
    }
  }

  /// Get a lighter variant of the role color with custom alpha
  static Color getRoleColorWithAlpha(UserRole role, double alpha) {
    return getRoleColor(role).withValues(alpha: alpha);
  }

  /// Get role color variants for different states
  static Color getRoleColorLight(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.errorLight;
      case UserRole.moderator:
        return DSColors.brandSecondary;
      case UserRole.user:
        return DSColors.successLight;
    }
  }

  /// Get dark variant of role colors for better contrast in dark themes
  static Color getRoleColorDark(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.errorDark;
      case UserRole.moderator:
        return DSColors.brandDark;
      case UserRole.user:
        return DSColors.successDark;
    }
  }

  /// Get role name as string for display purposes
  static String getRoleName(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Admin';
      case UserRole.moderator:
        return 'Moderator';
      case UserRole.user:
        return 'User';
    }
  }

  /// Get role description for UI display
  static String getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full system access and user management';
      case UserRole.moderator:
        return 'Content moderation and user verification';
      case UserRole.user:
        return 'Standard user access and features';
    }
  }

  /// Get permissions list for a specific role
  static List<String> getRolePermissions(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return [
          'Full system administration access',
          'Manage all user accounts and roles',
          'Access to system configuration',
          'View all application data',
          'Manage content and moderation',
          'System backup and maintenance',
        ];
      case UserRole.moderator:
        return [
          'Content moderation and review',
          'User verification and status management',
          'Community guidelines enforcement',
          'Report management and resolution',
          'Basic user account management',
        ];
      case UserRole.user:
        return [
          'Standard application features',
          'Personal profile management',
          'Content creation and sharing',
          'Basic community interaction',
        ];
    }
  }

  /// Check if role has elevated privileges
  static bool isElevatedRole(UserRole role) {
    return role == UserRole.admin || role == UserRole.moderator;
  }

  /// Get role priority level (higher number = higher priority)
  static int getRolePriority(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 3;
      case UserRole.moderator:
        return 2;
      case UserRole.user:
        return 1;
    }
  }
}
