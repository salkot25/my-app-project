import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/auth_provider.dart';
import 'user_detail_dialog.dart';

class UserCard extends ConsumerWidget {
  final User user;
  final bool isCurrentUser;
  final bool isEnabled;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final Function(UserRole)? onRoleChanged;
  final Function(UserStatus)? onStatusChanged;

  const UserCard({
    super.key,
    required this.user,
    required this.isCurrentUser,
    required this.isEnabled,
    this.onEdit,
    this.onDelete,
    this.onRoleChanged,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: isEnabled ? () => _showUserDetail(context, ref) : null,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: DSTokens.spaceL,
          vertical: DSTokens.spaceS,
        ),
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          border: Border.all(color: ref.colors.border),
          boxShadow: [
            BoxShadow(
              color: DSColors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(DSTokens.spaceL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User header (name, email, badges)
              _buildUserHeader(ref),
              const SizedBox(height: DSTokens.spaceM),

              // User details (role, status)
              _buildUserDetails(ref),
            ],
          ),
        ),
      ),
    );
  }

  void _showUserDetail(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    final currentUser = authState.domainUser;
    final canManageUser =
        currentUser?.canViewAllUsers == true && currentUser?.uid != user.uid;

    showDialog(
      context: context,
      builder: (context) => UserDetailDialog(
        user: user,
        onRoleChanged: canManageUser && currentUser?.canChangeRoles == true
            ? onRoleChanged
            : null,
        onStatusChanged: canManageUser && currentUser?.canVerifyUsers == true
            ? onStatusChanged
            : null,
      ),
    );
  }

  Widget _buildUserHeader(WidgetRef ref) {
    return Row(
      children: [
        // Avatar placeholder
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _getRoleColor(user.role).withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: _getRoleColor(user.role).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
              style: DSTypography.headlineMedium.copyWith(
                color: _getRoleColor(user.role),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: DSTokens.spaceM),

        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      user.name,
                      style: DSTypography.headlineMedium.copyWith(
                        color: ref.colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentUser) ...[
                    const SizedBox(width: DSTokens.spaceS),
                    _buildCurrentUserBadge(ref),
                  ],
                  const Spacer(),
                  // Delete button (only icon)
                  if (onDelete != null && !isCurrentUser)
                    GestureDetector(
                      onTap: isEnabled ? onDelete : null,
                      child: Container(
                        padding: const EdgeInsets.all(DSTokens.spaceS),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(DSTokens.radiusS),
                          border: Border.all(
                            color: const Color(0xFFEF4444).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.delete_outline,
                          size: 16,
                          color: const Color(
                            0xFFEF4444,
                          ).withOpacity(isEnabled ? 1.0 : 0.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: DSTokens.spaceXS),
              Text(
                user.email,
                style: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textSecondary,
                  fontSize: 14,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentUserBadge(WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceS,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSTokens.spaceS),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        'You',
        style: DSTypography.labelMedium.copyWith(
          color: const Color(0xFF10B981),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildUserDetails(WidgetRef ref) {
    return Row(
      children: [
        // Role badge
        _buildBadge(
          ref,
          user.role.value.toUpperCase(),
          _getRoleColor(user.role),
          Icons.admin_panel_settings_rounded,
        ),
        const SizedBox(width: DSTokens.spaceM),

        // Status badge
        _buildBadge(
          ref,
          user.status.value.toUpperCase(),
          _getStatusColor(user.status),
          _getStatusIcon(user.status),
        ),
      ],
    );
  }

  Widget _buildBadge(WidgetRef ref, String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceM,
        vertical: DSTokens.spaceS,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(DSTokens.radiusS),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: DSTokens.spaceS),
          Text(
            label,
            style: DSTypography.labelMedium.copyWith(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFFDC2626); // Modern red
      case UserRole.moderator:
        return const Color(0xFF3498DB); // Modern blue
      case UserRole.user:
        return const Color(0xFF6B7280); // Modern gray
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return const Color(0xFF10B981); // Modern green
      case UserStatus.unverified:
        return const Color(0xFFF59E0B); // Modern amber
      case UserStatus.suspended:
        return const Color(0xFFEF4444); // Modern red
    }
  }

  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return Icons.verified_outlined;
      case UserStatus.unverified:
        return Icons.pending_outlined;
      case UserStatus.suspended:
        return Icons.block_outlined;
    }
  }
}
