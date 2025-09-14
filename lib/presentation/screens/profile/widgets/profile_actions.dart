import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/utils/theme_colors.dart';
import '../../../../design_system/providers/theme_provider.dart';
import '../../../../domain/entities/user.dart';
import '../../../providers/auth_provider.dart';
import 'theme_mode_selector.dart';

/// Enhanced ProfileActions with senior UX principles:
/// 1. Better information architecture with logical grouping
/// 2. Enhanced accessibility and usability
/// 3. Optimized dark mode support
/// 4. Micro-interactions for better feedback
/// 5. Mobile-first responsive design
class ProfileActions extends ConsumerStatefulWidget {
  final User currentUser;

  const ProfileActions({super.key, required this.currentUser});

  @override
  ConsumerState<ProfileActions> createState() => _ProfileActionsState();
}

class _ProfileActionsState extends ConsumerState<ProfileActions>
    with TickerProviderStateMixin {
  bool _notificationsEnabled = true; // TODO: Get from settings
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _showAboutDialog() {
    final isDark = ref.watch(isDarkModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ref.colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceS),
              decoration: BoxDecoration(
                color: DSColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
              child: Icon(
                Icons.info_outline_rounded,
                color: DSColors.info,
                size: DSTokens.fontL,
              ),
            ),
            const SizedBox(width: DSTokens.spaceM),
            Text(
              'About Application',
              style: DSTypography.headlineSmall.copyWith(
                color: ref.colors.textPrimary,
                fontWeight: DSTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
              label: 'Version',
              value: '1.0.0',
              icon: Icons.tag_rounded,
            ),
            const SizedBox(height: DSTokens.spaceS),
            _buildInfoRow(
              label: 'Build',
              value:
                  '${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}',
              icon: Icons.build_rounded,
            ),
            const SizedBox(height: DSTokens.spaceM),
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceM),
              decoration: BoxDecoration(
                color: isDark ? ref.colors.surfaceElevated : DSColors.neutral50,
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
                border: Border.all(color: ref.colors.border, width: 1),
              ),
              child: Text(
                'A modern profile management application built with Flutter and Firebase, designed with accessibility and user experience in mind.',
                style: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textPrimary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: ref.colors.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: DSTokens.spaceL,
                vertical: DSTokens.spaceM,
              ),
            ),
            child: Text(
              'Close',
              style: DSTypography.buttonMedium.copyWith(
                fontWeight: DSTokens.fontWeightMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: DSTokens.fontM, color: ref.colors.textTertiary),
        const SizedBox(width: DSTokens.spaceS),
        Text(
          '$label:',
          style: DSTypography.bodyMedium.copyWith(
            color: ref.colors.textSecondary,
            fontWeight: DSTokens.fontWeightMedium,
          ),
        ),
        const SizedBox(width: DSTokens.spaceS),
        Expanded(
          child: Text(
            value,
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textPrimary,
              fontWeight: DSTokens.fontWeightSemiBold,
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ref.colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceS),
              decoration: BoxDecoration(
                color: DSColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
              child: Icon(
                Icons.logout_rounded,
                color: DSColors.error,
                size: DSTokens.fontL,
              ),
            ),
            const SizedBox(width: DSTokens.spaceM),
            Text(
              'Logout Confirmation',
              style: DSTypography.headlineSmall.copyWith(
                color: DSColors.error,
                fontWeight: DSTokens.fontWeightBold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to logout from your account?',
              style: DSTypography.bodyLarge.copyWith(
                color: ref.colors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: DSTokens.spaceS),
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceM),
              decoration: BoxDecoration(
                color: DSColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
                border: Border.all(
                  color: DSColors.warning.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: DSColors.warning,
                    size: DSTokens.fontM,
                  ),
                  const SizedBox(width: DSTokens.spaceS),
                  Expanded(
                    child: Text(
                      'You will need to sign in again to access your account.',
                      style: DSTypography.bodySmall.copyWith(
                        color: DSColors.warning,
                        fontWeight: DSTokens.fontWeightMedium,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: ref.colors.textSecondary,
              padding: const EdgeInsets.symmetric(
                horizontal: DSTokens.spaceL,
                vertical: DSTokens.spaceM,
              ),
            ),
            child: Text(
              'Cancel',
              style: DSTypography.buttonMedium.copyWith(
                fontWeight: DSTokens.fontWeightMedium,
              ),
            ),
          ),
          const SizedBox(width: DSTokens.spaceS),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: DSColors.error,
              foregroundColor: DSColors.textOnColor,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: DSTokens.spaceL,
                vertical: DSTokens.spaceM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(DSTokens.radiusM),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout_rounded, size: DSTokens.fontM),
                const SizedBox(width: DSTokens.spaceS),
                Text(
                  'Logout',
                  style: DSTypography.buttonMedium.copyWith(
                    fontWeight: DSTokens.fontWeightSemiBold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });

    // Enhanced feedback with haptic
    if (value) {
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.selectionClick();
    }

    // Improved snackbar feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              value
                  ? Icons.notifications_active_rounded
                  : Icons.notifications_off_rounded,
              color: DSColors.textOnColor,
              size: DSTokens.fontM,
            ),
            const SizedBox(width: DSTokens.spaceS),
            Text(
              'Notifications ${value ? 'enabled' : 'disabled'}',
              style: DSTypography.bodyMedium.copyWith(
                color: DSColors.textOnColor,
                fontWeight: DSTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
        backgroundColor: value ? DSColors.success : DSColors.warning,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(DSTokens.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showManageUsersInfo() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: DSColors.textOnColor,
              size: DSTokens.fontM,
            ),
            const SizedBox(width: DSTokens.spaceS),
            Expanded(
              child: Text(
                'Users management is available in the Users tab at the bottom navigation',
                style: DSTypography.bodyMedium.copyWith(
                  color: DSColors.textOnColor,
                  fontWeight: DSTokens.fontWeightMedium,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: DSColors.info,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(DSTokens.spaceM),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
          // Cleaner approach: Remove border for minimal appearance
          boxShadow: [
            BoxShadow(
              color: ref.colors.shadowColor.withValues(alpha: 0.15),
              blurRadius: DSTokens.spaceXS,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Section
            _buildSectionHeader('Settings', Icons.settings_rounded),

            _buildMenuTile(
              icon: Icons.notifications_outlined,
              title: 'Push Notifications',
              subtitle: 'Receive updates and alerts',
              trailing: Switch.adaptive(
                value: _notificationsEnabled,
                onChanged: _toggleNotifications,
                activeColor: _getRoleColor(widget.currentUser.role),
                activeTrackColor: _getRoleColor(
                  widget.currentUser.role,
                ).withValues(alpha: 0.3),
                inactiveThumbColor: ref.colors.textTertiary,
                inactiveTrackColor: ref.colors.surfaceContainer,
              ),
              onTap: null, // Switch handles the interaction
            ),

            const SizedBox(height: DSTokens.spaceS),

            // Theme Selection
            ThemeModeSelector(currentUser: widget.currentUser),

            _buildSectionDivider(),

            // Admin Section (Conditional)
            if (widget.currentUser.canViewAllUsers) ...[
              _buildSectionHeader(
                'Administration',
                Icons.admin_panel_settings_rounded,
              ),

              _buildMenuTile(
                icon: Icons.people_outline_rounded,
                title: 'Manage Users',
                subtitle: 'Available in Users tab below',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DSTokens.spaceS,
                    vertical: DSTokens.spaceXS,
                  ),
                  decoration: BoxDecoration(
                    color: DSColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSTokens.radiusS),
                    border: Border.all(
                      color: DSColors.info.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'Users Tab',
                    style: DSTypography.labelSmall.copyWith(
                      color: DSColors.info,
                      fontWeight: DSTokens.fontWeightMedium,
                    ),
                  ),
                ),
                onTap: _showManageUsersInfo,
              ),

              _buildSectionDivider(),
            ],

            // Information Section
            _buildSectionHeader('Information', Icons.info_rounded),

            _buildMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'About Application',
              subtitle: 'Version and app information',
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: ref.colors.textTertiary,
                size: DSTokens.fontL,
              ),
              onTap: _showAboutDialog,
            ),

            _buildSectionDivider(),

            // Account Section
            _buildSectionHeader(
              'Account',
              Icons.person_rounded,
              isDestructive: true,
            ),

            _buildMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'Sign out from your account',
              trailing: Container(
                padding: const EdgeInsets.all(DSTokens.spaceXS),
                decoration: BoxDecoration(
                  color: DSColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSTokens.radiusS),
                ),
                child: Icon(
                  Icons.logout_rounded,
                  color: DSColors.error,
                  size: DSTokens.fontM,
                ),
              ),
              onTap: _showLogoutConfirmation,
              isDestructive: true,
            ),

            const SizedBox(height: DSTokens.spaceS),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    IconData icon, {
    bool isDestructive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSTokens.spaceL,
        DSTokens.spaceL,
        DSTokens.spaceL,
        DSTokens.spaceS,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: DSTokens.fontM,
            color: isDestructive ? DSColors.error : ref.colors.textSecondary,
          ),
          const SizedBox(width: DSTokens.spaceS),
          Text(
            title,
            style: DSTypography.labelLarge.copyWith(
              color: isDestructive ? DSColors.error : ref.colors.textSecondary,
              fontWeight: DSTokens.fontWeightBold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceL,
        vertical: DSTokens.spaceM,
      ),
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, ref.colors.border, Colors.transparent],
          stops: const [0.0, 0.5, 1.0],
        ),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSTokens.spaceL,
            vertical: DSTokens.spaceM,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSTokens.spaceS),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(DSTokens.spaceS),
                  border: Border.all(
                    color: iconColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(icon, color: iconColor, size: DSTokens.fontL),
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
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: DSTokens.spaceXS / 2),
                    Text(
                      subtitle,
                      style: DSTypography.bodySmall.copyWith(
                        color: ref.colors.textSecondary,
                        letterSpacing: 0,
                        height: 1.3,
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
}
