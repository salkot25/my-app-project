import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';
import 'edit_profile_dialog.dart';
import 'password_change_dialog.dart';

class ProfileDetailDialog extends ConsumerWidget {
  final User currentUser;

  const ProfileDetailDialog({super.key, required this.currentUser});

  Color _getRoleColor(UserRole role, WidgetRef ref) {
    switch (role) {
      case UserRole.admin:
        return DSColors.error;
      case UserRole.moderator:
        return DSColors.brandPrimary;
      case UserRole.user:
        return ref.colors.textSecondary;
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

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => PasswordChangeDialog(currentUser: currentUser),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(currentUser: currentUser),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: DSColors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420, maxHeight: 600),
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusXL),
          boxShadow: [DSTokens.shadowL],
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
                    _getRoleColor(currentUser.role, ref),
                    _getRoleColor(currentUser.role, ref).withValues(alpha: 0.8),
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
                    top: -DSTokens.fontL, // -20px
                    right: -DSTokens.fontL, // -20px
                    child: Container(
                      width: DSTokens.spaceXXL - DSTokens.spaceXS, // 60px
                      height: DSTokens.spaceXXL - DSTokens.spaceXS, // 60px
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DSColors.textOnColor.withValues(alpha: 0.1),
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
                              color: DSColors.textOnColor.withValues(
                                alpha: 0.8,
                              ),
                              size: DSTokens.spaceL,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: DSColors.textOnColor.withValues(
                                alpha: 0.2,
                              ),
                              padding: const EdgeInsets.all(DSTokens.spaceS),
                            ),
                          ),
                        ),

                        const SizedBox(height: DSTokens.spaceS),

                        // Profile Avatar
                        Container(
                          width:
                              DSTokens.spaceXXL * 2 + DSTokens.fontL, // 100px
                          height:
                              DSTokens.spaceXXL * 2 + DSTokens.fontL, // 100px
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                DSColors.textOnColor,
                                DSColors.textOnColor.withValues(alpha: 0.95),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(
                              color: DSColors.textOnColor,
                              width: DSTokens.spaceXS, // 4px
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: DSColors.black.withValues(alpha: 0.2),
                                blurRadius: DSTokens.fontL, // 20px
                                offset: const Offset(0, DSTokens.spaceS),
                                spreadRadius: DSTokens.spaceXS / 2, // 2px
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: DSTokens.spaceXL + DSTokens.spaceXS, // 46px
                            backgroundColor: DSColors.transparent,
                            child: Text(
                              currentUser.name.isNotEmpty
                                  ? currentUser.name[0].toUpperCase()
                                  : 'U',
                              style: DSTypography.displayLarge.copyWith(
                                color: _getRoleColor(currentUser.role, ref),
                                fontWeight: DSTokens.fontWeightBold,
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
                            color: DSColors.textOnColor,
                            fontWeight: DSTokens.fontWeightBold,
                            letterSpacing: -1,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: DSTokens.spaceS),

                        // Role and Status Badges
                        Wrap(
                          spacing: DSTokens.spaceS,
                          alignment: WrapAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSTokens.spaceM,
                                vertical: DSTokens.spaceXS,
                              ),
                              decoration: BoxDecoration(
                                color: DSColors.textOnColor.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(
                                  DSTokens.spaceM,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getRoleIcon(currentUser.role),
                                    size: DSTokens.fontS,
                                    color: _getRoleColor(currentUser.role, ref),
                                  ),
                                  const SizedBox(width: DSTokens.spaceXS),
                                  Text(
                                    currentUser.role.value.toUpperCase(),
                                    style: DSTypography.labelSmall.copyWith(
                                      color: _getRoleColor(
                                        currentUser.role,
                                        ref,
                                      ),
                                      fontWeight: DSTokens.fontWeightBold,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: DSTokens.spaceM,
                                vertical: DSTokens.spaceXS,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(currentUser.status),
                                borderRadius: BorderRadius.circular(
                                  DSTokens.spaceM,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _getStatusIcon(currentUser.status),
                                    size: DSTokens.fontS,
                                    color: DSColors.textOnColor,
                                  ),
                                  const SizedBox(width: DSTokens.spaceXS),
                                  Text(
                                    currentUser.status.value.toUpperCase(),
                                    style: DSTypography.labelSmall.copyWith(
                                      color: DSColors.textOnColor,
                                      fontWeight: DSTokens.fontWeightBold,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ],
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
                      ref,
                      'Email Address',
                      currentUser.email,
                      Icons.email_rounded,
                      _getRoleColor(currentUser.role, ref),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // User ID Section
                    _buildDetailRow(
                      ref,
                      'User ID',
                      currentUser.uid.length > 20
                          ? '${currentUser.uid.substring(0, 20)}...'
                          : currentUser.uid,
                      Icons.fingerprint_rounded,
                      _getRoleColor(currentUser.role, ref),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // Member Since
                    _buildDetailRow(
                      ref,
                      'Member Since',
                      '${currentUser.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}',
                      Icons.calendar_today_rounded,
                      _getRoleColor(currentUser.role, ref),
                    ),

                    const SizedBox(height: DSTokens.spaceM),

                    // Last Updated
                    _buildDetailRow(
                      ref,
                      'Last Updated',
                      '${currentUser.updatedAt.day}/${currentUser.updatedAt.month}/${currentUser.updatedAt.year}',
                      Icons.update_rounded,
                      _getRoleColor(currentUser.role, ref),
                    ),

                    const SizedBox(height: DSTokens.spaceL),

                    // Action Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showChangePasswordDialog(context);
                            },
                            icon: const Icon(
                              Icons.lock_reset_rounded,
                              size: DSTokens.fontL,
                            ),
                            label: Text(
                              'Change Password',
                              style: DSTypography.buttonMedium.copyWith(
                                color: DSColors.textOnColor,
                                fontWeight: DSTokens.fontWeightSemiBold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _getRoleColor(
                                currentUser.role,
                                ref,
                              ),
                              foregroundColor: DSColors.textOnColor,
                              elevation: 0,
                              shadowColor: DSColors.transparent,
                              padding: const EdgeInsets.symmetric(
                                vertical: DSTokens.spaceM,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DSTokens.radiusM,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: DSTokens.spaceM),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showEditProfileDialog(context);
                            },
                            icon: Icon(
                              Icons.edit_rounded,
                              size: DSTokens.fontL,
                              color: _getRoleColor(currentUser.role, ref),
                            ),
                            label: Text(
                              'Edit Profile',
                              style: DSTypography.buttonMedium.copyWith(
                                color: _getRoleColor(currentUser.role, ref),
                                fontWeight: DSTokens.fontWeightSemiBold,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: ref.colors.surfaceContainer,
                              foregroundColor: _getRoleColor(
                                currentUser.role,
                                ref,
                              ),
                              side: BorderSide(
                                color: _getRoleColor(currentUser.role, ref),
                                width: DSTokens.spaceXXS / 2 + 0.5, // 1.5px
                              ),
                              padding: const EdgeInsets.symmetric(
                                vertical: DSTokens.spaceM,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  DSTokens.radiusM,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    WidgetRef ref,
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
        border: Border.all(
          color: ref.colors.border,
          width: DSTokens.spaceXXS / 2, // 1px
        ),
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
                    fontWeight: DSTokens.fontWeightMedium,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: DSTokens.spaceXS / 2), // 2px
                Text(
                  value,
                  style: DSTypography.bodyMedium.copyWith(
                    color: ref.colors.textPrimary,
                    fontWeight: DSTokens.fontWeightSemiBold,
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
