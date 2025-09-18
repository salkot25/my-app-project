import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/entities/user.dart';
import '../../../../design_system/design_system.dart';
import '../../../../design_system/utils/role_colors.dart';
import '../../../../design_system/utils/status_utils.dart';

/// Professional Business Card Style ProfileHeader:
/// 1. Clean, business card-like layout with proper information hierarchy
/// 2. Theme-aware colors for perfect dark mode support
/// 3. Enhanced visual elements with professional styling
/// 4. Comprehensive user information display
/// 5. Mobile-optimized responsive design with elegant spacing
class ProfileHeader extends ConsumerWidget {
  final User currentUser;
  final VoidCallback? onTap;

  const ProfileHeader({super.key, required this.currentUser, this.onTap});

  // Format member since date to be readable
  String _formatMemberSince(DateTime createdAt) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${monthNames[createdAt.month - 1]} ${createdAt.year}';
  }

  // Build professional avatar with company-style design
  Widget _buildAvatar(WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Stack(
      children: [
        Container(
          width: 80, // Larger professional size
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ref.colors.surface,
            border: Border.all(
              color: RoleColors.getRoleColorWithAlpha(
                currentUser.role,
                isDark ? 0.4 : 0.3,
              ),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: ref.colors.shadowColor.withValues(alpha: 0.2),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 37,
            backgroundColor: RoleColors.getRoleColorWithAlpha(
              currentUser.role,
              isDark ? 0.15 : 0.1,
            ),
            child: Text(
              currentUser.name.isNotEmpty
                  ? currentUser.name[0].toUpperCase()
                  : 'U',
              style: DSTypography.headlineMedium.copyWith(
                color: RoleColors.getRoleColor(currentUser.role),
                fontWeight: DSTokens.fontWeightBold,
              ),
            ),
          ),
        ),
        // Status indicator badge on avatar
        Positioned(
          bottom: 2,
          right: 2,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: StatusUtils.getStatusColor(currentUser.status),
              shape: BoxShape.circle,
              border: Border.all(color: ref.colors.surface, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Icon(
              StatusUtils.getStatusIcon(currentUser.status),
              size: 10,
              color: DSColors.textOnColor,
            ),
          ),
        ),
      ],
    );
  }

  // Build company-style information section
  Widget _buildUserInfo(WidgetRef ref) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name with professional styling
          Text(
            currentUser.name,
            style: DSTypography.headlineSmall.copyWith(
              fontWeight: DSTokens.fontWeightBold,
              color: ref.colors.textPrimary,
              letterSpacing: -0.5,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: DSTokens.spaceXS),

          // Role title with professional emphasis
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceS,
              vertical: DSTokens.spaceXS / 2,
            ),
            decoration: BoxDecoration(
              color: RoleColors.getRoleColorWithAlpha(currentUser.role, 0.1),
              borderRadius: BorderRadius.circular(DSTokens.radiusS),
              border: Border.all(
                color: RoleColors.getRoleColorWithAlpha(currentUser.role, 0.2),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  RoleColors.getRoleIcon(currentUser.role),
                  size: DSTokens.fontS,
                  color: RoleColors.getRoleColor(currentUser.role),
                ),
                const SizedBox(width: DSTokens.spaceXS),
                Text(
                  currentUser.role.value.toUpperCase(),
                  style: DSTypography.labelSmall.copyWith(
                    color: RoleColors.getRoleColor(currentUser.role),
                    fontWeight: DSTokens.fontWeightBold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: DSTokens.spaceS),

          // Contact information
          _buildContactInfo(ref),
        ],
      ),
    );
  }

  // Build professional contact information
  Widget _buildContactInfo(WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email
        Row(
          children: [
            Icon(
              Icons.email_outlined,
              size: DSTokens.fontM,
              color: ref.colors.textTertiary,
            ),
            const SizedBox(width: DSTokens.spaceS),
            Expanded(
              child: Text(
                currentUser.email,
                style: DSTypography.bodyMedium.copyWith(
                  color: ref.colors.textSecondary,
                  fontWeight: DSTokens.fontWeightMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: DSTokens.spaceS),

        // Member since (using real createdAt data)
        Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: DSTokens.fontM,
              color: ref.colors.textTertiary,
            ),
            const SizedBox(width: DSTokens.spaceS),
            Text(
              'Member since ${_formatMemberSince(currentUser.createdAt)}',
              style: DSTypography.bodySmall.copyWith(
                color: ref.colors.textSecondary,
                fontWeight: DSTokens.fontWeightMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        // Professional gradient background
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ref.colors.surface,
            ref.colors.surfaceContainer.withValues(alpha: 0.3),
          ],
        ),
        border: Border.all(color: ref.colors.border, width: 1),
        boxShadow: [
          BoxShadow(
            color: ref.colors.shadowColor.withValues(
              alpha: isDark ? 0.3 : 0.15,
            ),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          // Additional inner shadow for depth
          BoxShadow(
            color: ref.colors.shadowColor.withValues(
              alpha: isDark ? 0.1 : 0.05,
            ),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
          child: Container(
            padding: const EdgeInsets.all(DSTokens.spaceL),
            child: Column(
              children: [
                // Main business card layout
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildAvatar(ref),
                    const SizedBox(width: DSTokens.spaceL),
                    _buildUserInfo(ref),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
