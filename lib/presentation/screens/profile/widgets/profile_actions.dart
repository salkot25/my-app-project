import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/auth_provider.dart';
import 'theme_mode_selector.dart';

class ProfileActions extends ConsumerStatefulWidget {
  final User currentUser;

  const ProfileActions({super.key, required this.currentUser});

  @override
  ConsumerState<ProfileActions> createState() => _ProfileActionsState();
}

class _ProfileActionsState extends ConsumerState<ProfileActions> {
  bool _notificationsEnabled = true; // TODO: Get from settings

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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ref.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
        ),
        title: Text(
          'About Application',
          style: DSTypography.headlineSmall.copyWith(
            color: ref.colors.textPrimary,
            fontWeight: DSTokens.fontWeightBold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0',
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSTokens.spaceS),
            Text(
              'A modern profile management application built with Flutter and Firebase.',
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _getRoleColor(widget.currentUser.role),
            ),
            child: Text('Close', style: DSTypography.buttonMedium),
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ref.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
        ),
        title: Text(
          'Logout',
          style: DSTypography.headlineSmall.copyWith(
            color: DSColors.error,
            fontWeight: DSTokens.fontWeightBold,
          ),
        ),
        content: Text(
          'Are you sure you want to logout from your account?',
          style: DSTypography.bodyMedium.copyWith(
            color: ref.colors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: DSColors.textSecondary,
            ),
            child: Text('Cancel', style: DSTypography.buttonMedium),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DSColors.error,
              foregroundColor: DSColors.textOnColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
            ),
            child: Text('Logout', style: DSTypography.buttonMedium),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });

    // Show feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Notifications ${value ? 'enabled' : 'disabled'}',
          style: DSTypography.bodyMedium.copyWith(color: DSColors.textOnColor),
        ),
        backgroundColor: _getRoleColor(widget.currentUser.role),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        boxShadow: [DSTokens.shadowS],
      ),
      child: Column(
        children: [
          // Show Manage Users only for users who can view all users
          if (widget.currentUser.canViewAllUsers) ...[
            _buildMenuTile(
              icon: Icons.people_outline_rounded,
              title: 'Manage Users',
              subtitle: 'Available in Users tab below',
              trailing: Icon(
                Icons.info_outline_rounded,
                color: ref.colors.textTertiary,
                size: DSTokens.fontL,
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Users management is available in the Users tab at the bottom',
                      style: DSTypography.bodyMedium.copyWith(
                        color: DSColors.textOnColor,
                      ),
                    ),
                    backgroundColor: DSColors.info,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(DSTokens.radiusM),
                    ),
                  ),
                );
              },
            ),

            _buildDivider(),
          ],

          // Settings
          _buildMenuTile(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Manage notification preferences',
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
              activeThumbColor: _getRoleColor(widget.currentUser.role),
              activeTrackColor: _getRoleColor(
                widget.currentUser.role,
              ).withValues(alpha: 0.3),
              inactiveThumbColor: DSColors.interactiveDisabled,
              inactiveTrackColor: DSColors.surfaceContainer,
            ),
            onTap: null, // No tap action for switch items
          ),

          _buildDivider(),

          // Theme Mode Selection
          ThemeModeSelector(currentUser: widget.currentUser),

          _buildDivider(),

          // Information
          _buildMenuTile(
            icon: Icons.info_outline_rounded,
            title: 'About Application',
            subtitle: 'App version and information',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: ref.colors.textTertiary,
              size: DSTokens.fontL,
            ),
            onTap: _showAboutDialog,
          ),

          _buildDivider(),

          // Logout
          _buildMenuTile(
            icon: Icons.logout_rounded,
            title: 'Logout',
            subtitle: 'Sign out from your account',
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: ref.colors.textTertiary,
              size: DSTokens.fontL,
            ),
            onTap: _showLogoutConfirmation,
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final iconColor = isDestructive ? DSColors.error : ref.colors.textSecondary;
    final titleColor = isDestructive ? DSColors.error : ref.colors.textPrimary;

    return Material(
      color: DSColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSTokens.spaceL,
            vertical: DSTokens.spaceM,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  DSTokens.spaceS + DSTokens.spaceXS,
                ), // 10px
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    DSTokens.spaceS + DSTokens.spaceXS,
                  ), // 10px
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                ),
              ),
              const SizedBox(width: DSTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: DSTypography.bodyLarge.copyWith(
                        color: titleColor,
                        fontWeight: DSTokens.fontWeightSemiBold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: DSTokens.spaceXS / 2), // 2px
                    Text(
                      subtitle,
                      style: DSTypography.bodySmall.copyWith(
                        color: ref.colors.textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSTokens.spaceM),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSTokens.spaceL),
      height: DSTokens.spaceXXS / 2, // 1px
      color: ref.colors.border,
    );
  }
}
