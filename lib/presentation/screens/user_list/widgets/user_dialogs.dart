import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/utils/theme_colors.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/user_role.dart';
import '../../../../domain/entities/user_status.dart';
import '../../../../design_system/utils/role_colors.dart';
import '../../../../design_system/utils/status_utils.dart';

class UserDialogs {
  static Future<UserRole?> showRoleSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    return showDialog<UserRole>(
      context: context,
      builder: (context) => _RoleSelectionDialog(user: user, ref: ref),
    );
  }

  static Future<UserStatus?> showStatusSelectionDialog(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    return showDialog<UserStatus>(
      context: context,
      builder: (context) => _StatusSelectionDialog(user: user, ref: ref),
    );
  }

  static Future<bool> showDeleteConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
    User user,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _DeleteConfirmationDialog(user: user, ref: ref),
    );
    return result ?? false;
  }
}

class _RoleSelectionDialog extends ConsumerWidget {
  final User user;
  final WidgetRef ref;

  const _RoleSelectionDialog({required this.user, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ref.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
      ),
      title: Text(
        'Change Role',
        style: DSTypography.headlineMedium.copyWith(
          color: ref.colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change role for ${user.name}:',
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: DSTokens.spaceL),
          ...UserRole.values.map((role) {
            return _buildRoleOption(context, ref, role);
          }),
        ],
      ),
      actions: [
        _buildDialogButton(
          ref,
          'Cancel',
          ref.colors.textSecondary,
          () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildRoleOption(BuildContext context, WidgetRef ref, UserRole role) {
    final isCurrentRole = role == user.role;
    final color = RoleColors.getRoleColor(role);

    return Container(
      margin: const EdgeInsets.only(bottom: DSTokens.spaceS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCurrentRole ? null : () => Navigator.of(context).pop(role),
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          child: Container(
            padding: const EdgeInsets.all(DSTokens.spaceM),
            decoration: BoxDecoration(
              color: isCurrentRole
                  ? color.withOpacity(0.1)
                  : ref.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
              border: Border.all(
                color: isCurrentRole
                    ? color.withOpacity(0.3)
                    : ref.colors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  RoleColors.getRoleIcon(role),
                  size: 20,
                  color: isCurrentRole ? color : ref.colors.textSecondary,
                ),
                const SizedBox(width: DSTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.value.toUpperCase(),
                        style: DSTypography.bodyMedium.copyWith(
                          color: isCurrentRole ? color : ref.colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        RoleColors.getRoleDescription(role),
                        style: DSTypography.bodyMedium.copyWith(
                          color: ref.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentRole)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSTokens.spaceS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(DSTokens.spaceS),
                    ),
                    child: Text(
                      'Current',
                      style: DSTypography.labelMedium.copyWith(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    WidgetRef ref,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: DSTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatusSelectionDialog extends ConsumerWidget {
  final User user;
  final WidgetRef ref;

  const _StatusSelectionDialog({required this.user, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ref.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
      ),
      title: Text(
        'Change Status',
        style: DSTypography.headlineMedium.copyWith(
          color: ref.colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change status for ${user.name}:',
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: DSTokens.spaceL),
          ...UserStatus.values.map((status) {
            return _buildStatusOption(context, ref, status);
          }),
        ],
      ),
      actions: [
        _buildDialogButton(
          ref,
          'Cancel',
          ref.colors.textSecondary,
          () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    WidgetRef ref,
    UserStatus status,
  ) {
    final isCurrentStatus = status == user.status;
    final color = StatusUtils.getStatusColor(status);
    final icon = StatusUtils.getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: DSTokens.spaceS),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCurrentStatus
              ? null
              : () => Navigator.of(context).pop(status),
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          child: Container(
            padding: const EdgeInsets.all(DSTokens.spaceM),
            decoration: BoxDecoration(
              color: isCurrentStatus
                  ? color.withOpacity(0.1)
                  : ref.colors.surfaceContainer,
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
              border: Border.all(
                color: isCurrentStatus
                    ? color.withOpacity(0.3)
                    : ref.colors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isCurrentStatus ? color : ref.colors.textSecondary,
                ),
                const SizedBox(width: DSTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.value.toUpperCase(),
                        style: DSTypography.bodyMedium.copyWith(
                          color: isCurrentStatus
                              ? color
                              : ref.colors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        StatusUtils.getStatusDescription(status),
                        style: DSTypography.bodyMedium.copyWith(
                          color: ref.colors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCurrentStatus)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSTokens.spaceS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(DSTokens.spaceS),
                    ),
                    child: Text(
                      'Current',
                      style: DSTypography.labelMedium.copyWith(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    WidgetRef ref,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: DSTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _DeleteConfirmationDialog extends ConsumerWidget {
  final User user;
  final WidgetRef ref;

  const _DeleteConfirmationDialog({required this.user, required this.ref});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ref.colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
      ),
      title: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: const Color(0xFFEF4444),
            size: 24,
          ),
          const SizedBox(width: DSTokens.spaceM),
          Text(
            'Delete User',
            style: DSTypography.headlineMedium.copyWith(
              color: ref.colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to delete this user?',
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: DSTokens.spaceM),
          Container(
            padding: const EdgeInsets.all(DSTokens.spaceM),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.05),
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
              border: Border.all(
                color: const Color(0xFFEF4444).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: DSTypography.bodyMedium.copyWith(
                    color: ref.colors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: DSTokens.spaceXS),
                Text(
                  user.email,
                  style: DSTypography.bodyMedium.copyWith(
                    color: ref.colors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: DSTokens.spaceS),
                Row(
                  children: [
                    _buildInfoChip(
                      ref,
                      user.role.value.toUpperCase(),
                      RoleColors.getRoleColor(user.role),
                    ),
                    const SizedBox(width: DSTokens.spaceS),
                    _buildInfoChip(
                      ref,
                      user.status.value.toUpperCase(),
                      StatusUtils.getStatusColor(user.status),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: DSTokens.spaceM),
          Text(
            'This action cannot be undone. The user will be permanently removed from the system.',
            style: DSTypography.bodyMedium.copyWith(
              color: const Color(0xFFEF4444),
              fontSize: 13,
            ),
          ),
        ],
      ),
      actions: [
        _buildDialogButton(
          ref,
          'Cancel',
          ref.colors.textSecondary,
          () => Navigator.of(context).pop(false),
        ),
        _buildDialogButton(
          ref,
          'Delete',
          const Color(0xFFEF4444),
          () => Navigator.of(context).pop(true),
        ),
      ],
    );
  }

  Widget _buildInfoChip(WidgetRef ref, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSTokens.spaceS),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: DSTypography.labelMedium.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDialogButton(
    WidgetRef ref,
    String label,
    Color color,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: DSTypography.bodyMedium.copyWith(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
