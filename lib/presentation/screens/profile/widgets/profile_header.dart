import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';

/// Dark Mode Optimized ProfileHeader following senior UX principles:
/// 1. Theme-aware colors for perfect dark mode support
/// 2. Adaptive shadows and elevations
/// 3. Enhanced contrast for both light/dark themes
/// 4. Consistent visual hierarchy across themes
/// 5. Mobile-optimized responsive design
class ProfileHeader extends ConsumerWidget {
  final User currentUser;
  final VoidCallback? onTap;

  const ProfileHeader({super.key, required this.currentUser, this.onTap});

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
        return Icons.verified_rounded;
      case UserStatus.unverified:
        return Icons.pending_rounded;
      case UserStatus.suspended:
        return Icons.block_rounded;
    }
  }

  // Build status indicator with dark mode support
  Widget _buildStatusIndicator(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceS,
        vertical: DSTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        // Dark mode: stronger alpha for better visibility
        color: _getStatusColor(
          currentUser.status,
        ).withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(DSTokens.radiusS),
        border: Border.all(
          // Dark mode: stronger border for better definition
          color: _getStatusColor(
            currentUser.status,
          ).withValues(alpha: isDark ? 0.5 : 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(currentUser.status),
            size: DSTokens.fontS,
            color: _getStatusColor(currentUser.status),
          ),
          const SizedBox(width: DSTokens.spaceXS),
          Text(
            currentUser.status.value,
            style: DSTypography.labelSmall.copyWith(
              color: _getStatusColor(currentUser.status),
              fontWeight: DSTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Build role badge with dark mode optimization
  Widget _buildRoleBadge(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceS,
        vertical: DSTokens.spaceXS,
      ),
      decoration: BoxDecoration(
        color: _getRoleColor(currentUser.role),
        borderRadius: BorderRadius.circular(DSTokens.radiusS),
        // Dark mode: Add subtle border for better definition
        border: isDark
            ? Border.all(
                color: _getRoleColor(currentUser.role).withValues(alpha: 0.3),
                width: 0.5,
              )
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getRoleIcon(currentUser.role),
            size: DSTokens.fontS,
            color: DSColors.textOnColor,
          ),
          const SizedBox(width: DSTokens.spaceXS),
          Text(
            currentUser.role.value,
            style: DSTypography.labelSmall.copyWith(
              color: DSColors.textOnColor,
              fontWeight: DSTokens.fontWeightMedium,
            ),
          ),
        ],
      ),
    );
  }

  // Dark mode optimized avatar with adaptive styling
  Widget _buildAvatar(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      width: DSTokens.spaceXXL * 1.5, // 60px - mobile-friendly
      height: DSTokens.spaceXXL * 1.5,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Dark mode: Use theme-aware surface color
        color: ref.colors.surface,
        border: Border.all(
          color: _getRoleColor(currentUser.role).withValues(
            // Dark mode: stronger border for better visibility
            alpha: isDark ? 0.4 : 0.2,
          ),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            // Dark mode: Adjusted shadow for better depth perception
            color: ref.colors.shadowColor,
            blurRadius: DSTokens.spaceS,
            offset: const Offset(0, DSTokens.spaceXS),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: DSTokens.spaceXL, // 32px
        backgroundColor: _getRoleColor(currentUser.role).withValues(
          // Dark mode: slightly stronger alpha for better contrast
          alpha: isDark ? 0.15 : 0.1,
        ),
        child: Text(
          currentUser.name.isNotEmpty ? currentUser.name[0].toUpperCase() : 'U',
          style: DSTypography.headlineSmall.copyWith(
            color: _getRoleColor(currentUser.role),
            fontWeight: DSTokens.fontWeightBold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(
          // Dark mode: Use theme-aware border color
          color: ref.colors.border,
          width: 1,
        ),
        // Dark mode: Use theme-aware surface color
        color: ref.colors.surface,
        // Dark mode: Enhanced shadow for better card definition
        boxShadow: [
          BoxShadow(
            color: ref.colors.shadowColor,
            blurRadius: isDark ? DSTokens.spaceS : DSTokens.spaceXS,
            offset: Offset(0, isDark ? DSTokens.spaceXS : DSTokens.spaceXS / 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(DSTokens.spaceL),
          decoration: BoxDecoration(
            // Dark mode: Remove gradient for better consistency
            color: ref.colors.surface,
            borderRadius: BorderRadius.circular(DSTokens.radiusL),
          ),
          child: Column(
            children: [
              // Main profile info row
              Row(
                children: [
                  _buildAvatar(ref),
                  const SizedBox(width: DSTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Primary: User name with theme-aware colors
                        Text(
                          currentUser.name,
                          style: DSTypography.headlineSmall.copyWith(
                            fontWeight: DSTokens.fontWeightBold,
                            // Dark mode: Use theme-aware primary text color
                            color: ref.colors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: DSTokens.spaceXS),

                        // Secondary: Email with theme-aware subtle styling
                        Text(
                          currentUser.email,
                          style: DSTypography.bodyMedium.copyWith(
                            // Dark mode: Use theme-aware secondary text color
                            color: ref.colors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: DSTokens.spaceM),

              // Badges section with dark mode optimization
              Row(
                children: [
                  _buildRoleBadge(ref),
                  const SizedBox(width: DSTokens.spaceS),
                  _buildStatusIndicator(ref),
                  const Spacer(),

                  // Clear CTA with theme-aware colors
                  if (onTap != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: DSTokens.fontM,
                          // Dark mode: Use theme-aware tertiary color
                          color: ref.colors.textTertiary,
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
