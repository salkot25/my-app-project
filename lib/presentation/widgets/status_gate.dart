import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_status.dart';
import '../providers/auth_provider.dart';
import 'role_gate.dart';

/// Widget that restricts access based on user verification status
class StatusGate extends ConsumerWidget {
  const StatusGate({
    super.key,
    required this.requiredStatus,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  /// Required user status to access the child widget
  final UserStatus requiredStatus;

  /// Widget to display when user has required status
  final Widget child;

  /// Widget to display when user doesn't have required status
  /// If null and showFallback is true, shows default status message
  final Widget? fallback;

  /// Whether to show fallback widget when access is denied
  /// If false, returns empty SizedBox
  final bool showFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    // If user is not authenticated
    if (currentUser == null) {
      if (!showFallback) return const SizedBox.shrink();

      return fallback ??
          const Card(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Authentication required',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // Check if user has the required status
    if (currentUser.status == requiredStatus) {
      return child;
    }

    // User doesn't have required status
    if (!showFallback) return const SizedBox.shrink();

    return fallback ?? _buildDefaultFallback(context, currentUser);
  }

  Widget _buildDefaultFallback(BuildContext context, currentUser) {
    final Color cardColor;
    final Color iconColor;
    final Color textColor;
    final IconData icon;
    final String title;
    final String description;

    switch (currentUser.status) {
      case UserStatus.unverified:
        cardColor = Colors.orange.shade100;
        iconColor = Colors.orange.shade700;
        textColor = Colors.orange.shade600;
        icon = Icons.pending;
        title = 'Account Pending Verification';
        description =
            'Your account is waiting for admin approval. Please contact support if this takes too long.';
        break;
      case UserStatus.suspended:
        cardColor = Colors.red.shade100;
        iconColor = Colors.red.shade700;
        textColor = Colors.red.shade600;
        icon = Icons.block;
        title = 'Account Suspended';
        description =
            'Your account has been suspended. Please contact support for assistance.';
        break;
      case UserStatus.verified:
      default:
        // This case shouldn't happen if requiredStatus is verified
        cardColor = Colors.green.shade100;
        iconColor = Colors.green.shade700;
        textColor = Colors.green.shade600;
        icon = Icons.check_circle;
        title = 'Account Verified';
        description = 'Your account is verified and active.';
        break;
    }

    return Card(
      color: cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(description, style: TextStyle(color: textColor)),
                  const SizedBox(height: 8),
                  Text(
                    'Required: ${requiredStatus.value} | Your status: ${currentUser.status.value}',
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget that restricts access to verified users only
class VerifiedGate extends ConsumerWidget {
  const VerifiedGate({
    super.key,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StatusGate(
      requiredStatus: UserStatus.verified,
      showFallback: showFallback,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that blocks access for suspended users
class NotSuspendedGate extends ConsumerWidget {
  const NotSuspendedGate({
    super.key,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    // If user is not authenticated
    if (currentUser == null) {
      if (!showFallback) return const SizedBox.shrink();

      return fallback ??
          const Card(
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Authentication required',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
    }

    // Allow access if user is not suspended
    if (currentUser.status != UserStatus.suspended) {
      return child;
    }

    // User is suspended
    if (!showFallback) return const SizedBox.shrink();

    return fallback ??
        Card(
          color: Colors.red.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.block, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Account Suspended',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your account has been suspended and you cannot access this content. Please contact support.',
                        style: TextStyle(color: Colors.red.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

/// Combined widget that requires both role and status checks
class RoleAndStatusGate extends ConsumerWidget {
  const RoleAndStatusGate({
    super.key,
    required this.allowedRoles,
    required this.requiredStatus,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  final List<UserRole> allowedRoles;
  final UserStatus requiredStatus;
  final Widget child;
  final Widget? fallback;
  final bool showFallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return StatusGate(
      requiredStatus: requiredStatus,
      showFallback: showFallback,
      child: RoleGate(
        allowedRoles: allowedRoles,
        showFallback: showFallback,
        fallback: fallback,
        child: child,
      ),
    );
  }
}
