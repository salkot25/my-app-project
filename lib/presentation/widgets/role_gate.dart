import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_role.dart';
import '../providers/auth_provider.dart';

/// Widget that restricts access based on user role
class RoleGate extends ConsumerWidget {
  const RoleGate({
    super.key,
    required this.allowedRoles,
    required this.child,
    this.fallback,
    this.showFallback = true,
  });

  /// List of roles that are allowed to see the child widget
  final List<UserRole> allowedRoles;

  /// Widget to display when user has required role
  final Widget child;

  /// Widget to display when user doesn't have required role
  /// If null and showFallback is true, shows default access denied message
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

    // Check if user's role is in the allowed roles list
    if (allowedRoles.contains(currentUser.role)) {
      return child;
    }

    // User doesn't have required role
    if (!showFallback) return const SizedBox.shrink();

    return fallback ??
        Card(
          color: Colors.orange.shade100,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.lock_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Access Denied',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                      Text(
                        'Required role: ${allowedRoles.map((r) => r.value).join(' or ')}',
                        style: TextStyle(color: Colors.orange.shade600),
                      ),
                      Text(
                        'Your role: ${currentUser.role.value}',
                        style: TextStyle(color: Colors.orange.shade600),
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

/// Widget that restricts access to admin users only
class AdminGate extends ConsumerWidget {
  const AdminGate({
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
    return RoleGate(
      allowedRoles: const [UserRole.admin],
      showFallback: showFallback,
      fallback: fallback,
      child: child,
    );
  }
}

/// Widget that restricts access to admin and moderator users
class ModeratorGate extends ConsumerWidget {
  const ModeratorGate({
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
    return RoleGate(
      allowedRoles: const [UserRole.admin, UserRole.moderator],
      showFallback: showFallback,
      fallback: fallback,
      child: child,
    );
  }
}
