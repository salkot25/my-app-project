import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';
import 'user_dialogs.dart';

class UserDetailDialog extends ConsumerStatefulWidget {
  final User user;
  final Function(UserRole)? onRoleChanged;
  final Function(UserStatus)? onStatusChanged;

  const UserDetailDialog({
    super.key,
    required this.user,
    this.onRoleChanged,
    this.onStatusChanged,
  });

  @override
  ConsumerState<UserDetailDialog> createState() => _UserDetailDialogState();
}

class _UserDetailDialogState extends ConsumerState<UserDetailDialog> {
  late User currentUser;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: DSTypography.bodyMedium.copyWith(color: DSColors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
      ),
    );
  }

  Future<void> _handleRoleChange() async {
    if (_isUpdating) return;

    final newRole = await UserDialogs.showRoleSelectionDialog(
      context,
      ref,
      currentUser,
    );

    if (newRole != null && newRole != currentUser.role) {
      setState(() {
        _isUpdating = true;
      });

      try {
        if (widget.onRoleChanged != null) {
          widget.onRoleChanged!(newRole);
          setState(() {
            currentUser = currentUser.copyWith(role: newRole);
          });
          _showSnackBar('Role updated successfully', DSColors.success);
        }
      } catch (e) {
        _showSnackBar('Error updating role: ${e.toString()}', DSColors.error);
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _handleStatusChange() async {
    if (_isUpdating) return;

    final newStatus = await UserDialogs.showStatusSelectionDialog(
      context,
      ref,
      currentUser,
    );

    if (newStatus != null && newStatus != currentUser.status) {
      setState(() {
        _isUpdating = true;
      });

      try {
        if (widget.onStatusChanged != null) {
          widget.onStatusChanged!(newStatus);
          setState(() {
            currentUser = currentUser.copyWith(status: newStatus);
          });
          _showSnackBar('Status updated successfully', DSColors.success);
        }
      } catch (e) {
        _showSnackBar('Error updating status: ${e.toString()}', DSColors.error);
      } finally {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.error;
      case UserRole.moderator:
        return DSColors.brandPrimary;
      case UserRole.user:
        return DSColors.textSecondary;
    }
  }

  IconData _getRoleIcon(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.moderator:
        return Icons.verified_user_rounded;
      case UserRole.user:
        return Icons.person_rounded;
    }
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return DSColors.success;
      case UserStatus.unverified:
        return DSColors.warning;
      case UserStatus.suspended:
        return DSColors.error;
    }
  }

  IconData _getStatusIcon(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return Icons.check_circle_rounded;
      case UserStatus.unverified:
        return Icons.pending_rounded;
      case UserStatus.suspended:
        return Icons.block_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520, maxHeight: 750),
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusXL),
          boxShadow: [
            BoxShadow(
              color: ref.colors.textPrimary.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(color: ref.colors.border, width: 0.5),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with gradient
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getRoleColor(currentUser.role),
                    _getRoleColor(currentUser.role).withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(DSTokens.radiusXL),
                  topRight: Radius.circular(DSTokens.radiusXL),
                ),
              ),
              child: Stack(
                children: [
                  // Decorative elements
                  Positioned(
                    top: -DSTokens.fontL,
                    right: -DSTokens.fontL,
                    child: Container(
                      width: DSTokens.spaceXXL - DSTokens.spaceXS,
                      height: DSTokens.spaceXXL - DSTokens.spaceXS,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DSColors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.all(DSTokens.spaceL),
                    child: Column(
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.close_rounded,
                              color: DSColors.white.withValues(alpha: 0.9),
                              size: DSTokens.spaceL,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: DSColors.white.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.all(DSTokens.spaceS),
                            ),
                          ),
                        ),

                        const SizedBox(height: DSTokens.spaceS),

                        // Profile Avatar
                        Container(
                          width: DSTokens.spaceXXL * 2 + DSTokens.fontL,
                          height: DSTokens.spaceXXL * 2 + DSTokens.fontL,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                DSColors.white,
                                DSColors.white.withValues(alpha: 0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: DSColors.white,
                              width: DSTokens.spaceXS,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DSColors.black.withValues(alpha: 0.2),
                                blurRadius: DSTokens.fontL,
                                offset: const Offset(0, DSTokens.spaceS),
                                spreadRadius: DSTokens.spaceXS / 2,
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: DSTokens.spaceXL + DSTokens.spaceXS,
                            backgroundColor: Colors.transparent,
                            child: Text(
                              currentUser.name.isNotEmpty
                                  ? currentUser.name[0].toUpperCase()
                                  : 'U',
                              style: DSTypography.displayLarge.copyWith(
                                color: _getRoleColor(currentUser.role),
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: DSTokens.spaceM),

                        // Name
                        Text(
                          currentUser.name,
                          style: DSTypography.headlineLarge.copyWith(
                            color: DSColors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: DSTokens.spaceS),

                        // Role and Status Badges
                        Wrap(
                          spacing: DSTokens.spaceS,
                          alignment: WrapAlignment.center,
                          children: [
                            // Role Badge (Clickable)
                            GestureDetector(
                              onTap:
                                  widget.onRoleChanged != null && !_isUpdating
                                  ? _handleRoleChange
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DSTokens.spaceM,
                                  vertical: DSTokens.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: DSColors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(
                                    DSTokens.spaceM,
                                  ),
                                  border: widget.onRoleChanged != null
                                      ? Border.all(
                                          color: DSColors.white.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getRoleIcon(currentUser.role),
                                      size: DSTokens.fontS,
                                      color: _getRoleColor(currentUser.role),
                                    ),
                                    const SizedBox(width: DSTokens.spaceXS),
                                    Text(
                                      currentUser.role.value.toUpperCase(),
                                      style: DSTypography.labelSmall.copyWith(
                                        color: _getRoleColor(currentUser.role),
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    if (widget.onRoleChanged != null &&
                                        !_isUpdating) ...[
                                      const SizedBox(width: DSTokens.spaceXS),
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 12,
                                        color: _getRoleColor(currentUser.role),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            // Status Badge (Clickable)
                            GestureDetector(
                              onTap:
                                  widget.onStatusChanged != null && !_isUpdating
                                  ? _handleStatusChange
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: DSTokens.spaceM,
                                  vertical: DSTokens.spaceXS,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(currentUser.status),
                                  borderRadius: BorderRadius.circular(
                                    DSTokens.spaceM,
                                  ),
                                  border: widget.onStatusChanged != null
                                      ? Border.all(
                                          color: DSColors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        )
                                      : null,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(currentUser.status),
                                      size: DSTokens.fontS,
                                      color: DSColors.white,
                                    ),
                                    const SizedBox(width: DSTokens.spaceXS),
                                    Text(
                                      currentUser.status.value.toUpperCase(),
                                      style: DSTypography.labelSmall.copyWith(
                                        color: DSColors.white,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                    if (widget.onStatusChanged != null &&
                                        !_isUpdating) ...[
                                      const SizedBox(width: DSTokens.spaceXS),
                                      const Icon(
                                        Icons.edit_rounded,
                                        size: 12,
                                        color: DSColors.white,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Detail Information
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(DSTokens.spaceL),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Section
                    _buildDetailRow(
                      'Email Address',
                      currentUser.email,
                      Icons.email_rounded,
                      _getRoleColor(currentUser.role),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // Status Details
                    _buildDetailRow(
                      'Status Details',
                      _getStatusDescription(currentUser.status),
                      _getStatusIcon(currentUser.status),
                      _getStatusColor(currentUser.status),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // Member Since
                    _buildDetailRow(
                      'Member Since',
                      '${currentUser.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}',
                      Icons.calendar_today_rounded,
                      _getRoleColor(currentUser.role),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // Last Updated
                    _buildDetailRow(
                      'Last Updated',
                      '${currentUser.updatedAt.day}/${currentUser.updatedAt.month}/${currentUser.updatedAt.year}',
                      Icons.update_rounded,
                      _getRoleColor(currentUser.role),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // Role & Permissions (Enhanced)
                    _buildRolePermissionCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRolePermissionCard() {
    final roleColor = _getRoleColor(currentUser.role);
    final permissions = _getRolePermissions(currentUser.role);

    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceL),
      decoration: BoxDecoration(
        color: ref.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(color: ref.colors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSTokens.spaceS),
                decoration: BoxDecoration(
                  color: roleColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSTokens.spaceS),
                ),
                child: Icon(
                  _getRoleIcon(currentUser.role),
                  color: roleColor,
                  size: DSTokens.fontL,
                ),
              ),
              const SizedBox(width: DSTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Role & Permissions',
                      style: DSTypography.labelMedium.copyWith(
                        color: ref.colors.textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      currentUser.role.value.toUpperCase(),
                      style: DSTypography.bodyMedium.copyWith(
                        color: roleColor,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: DSTokens.spaceM),

          // Description
          Text(
            _getRoleDescription(currentUser.role),
            style: DSTypography.bodySmall.copyWith(
              color: ref.colors.textSecondary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: DSTokens.spaceM),

          // Permissions
          Text(
            'Permissions:',
            style: DSTypography.labelSmall.copyWith(
              color: ref.colors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: DSTokens.spaceS),

          ...permissions.map(
            (permission) => Padding(
              padding: const EdgeInsets.only(bottom: DSTokens.spaceXS),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 14, color: roleColor),
                  const SizedBox(width: DSTokens.spaceS),
                  Expanded(
                    child: Text(
                      permission,
                      style: DSTypography.bodySmall.copyWith(
                        color: ref.colors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getRolePermissions(UserRole role) {
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

  String _getRoleDescription(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return 'Full system access and user management';
      case UserRole.moderator:
        return 'Content moderation and user verification';
      case UserRole.user:
        return 'Standard user access and features';
    }
  }

  String _getStatusDescription(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return 'Account is verified and fully active';
      case UserStatus.unverified:
        return 'Account pending verification';
      case UserStatus.suspended:
        return 'Account access has been suspended';
    }
  }

  Widget _buildDetailRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceM),
      decoration: BoxDecoration(
        color: ref.colors.surfaceContainer,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        border: Border.all(color: ref.colors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(DSTokens.spaceS),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSTokens.spaceS),
            ),
            child: Icon(icon, color: color, size: DSTokens.fontL),
          ),
          const SizedBox(width: DSTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DSTypography.labelMedium.copyWith(
                    color: ref.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: DSTypography.bodyMedium.copyWith(
                    color: ref.colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
