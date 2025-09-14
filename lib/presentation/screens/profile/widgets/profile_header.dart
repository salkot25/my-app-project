import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: DSColors.transparent,
      borderRadius: BorderRadius.circular(DSTokens.radiusL),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        child: Container(
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
            borderRadius: BorderRadius.circular(DSTokens.radiusL),
            boxShadow: [
              DSTokens.shadowM,
              BoxShadow(
                color: _getRoleColor(currentUser.role).withValues(alpha: 0.3),
                blurRadius: DSTokens.spaceM,
                offset: const Offset(0, DSTokens.spaceXS),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: -DSTokens.spaceL,
                right: -DSTokens.spaceL,
                child: Container(
                  width: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
                  height: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DSColors.textOnColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -DSTokens.fontL, // -20px
                left: -DSTokens.fontL, // -20px
                child: Container(
                  width: DSTokens.spaceXXL - DSTokens.spaceXS, // 60px
                  height: DSTokens.spaceXXL - DSTokens.spaceXS, // 60px
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: DSColors.textOnColor.withValues(alpha: 0.05),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.all(DSTokens.spaceL),
                child: Row(
                  children: [
                    // Avatar Section
                    Container(
                      width: DSTokens.spaceXXL * 2 + DSTokens.fontL, // 88px
                      height: DSTokens.spaceXXL * 2 + DSTokens.fontL, // 88px
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
                          width: DSTokens.spaceXS / 2 + 1, // 3px
                        ),
                        boxShadow: [
                          DSTokens.shadowL,
                          BoxShadow(
                            color: _getRoleColor(
                              currentUser.role,
                            ).withValues(alpha: 0.2),
                            blurRadius: DSTokens.spaceM,
                            offset: const Offset(0, DSTokens.spaceXS),
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _getRoleColor(
                                currentUser.role,
                              ).withValues(alpha: 0.1),
                              _getRoleColor(
                                currentUser.role,
                              ).withValues(alpha: 0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: DSTokens.spaceXL + DSTokens.spaceS, // 40px
                          backgroundColor: DSColors.transparent,
                          child: Text(
                            currentUser.name.isNotEmpty
                                ? currentUser.name[0].toUpperCase()
                                : 'U',
                            style: DSTypography.displayMedium.copyWith(
                              color: _getRoleColor(currentUser.role),
                              fontWeight: DSTokens.fontWeightBold,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: DSTokens.spaceL),

                    // Info Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Name with improved hierarchy
                          Text(
                            currentUser.name,
                            style: DSTypography.headlineMedium.copyWith(
                              color: DSColors.textOnColor,
                              fontWeight: DSTokens.fontWeightBold,
                              letterSpacing: -0.8,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: DSTokens.spaceXS),

                          // Role and Status Badges
                          Wrap(
                            spacing: DSTokens.spaceS,
                            runSpacing: DSTokens.spaceXS,
                            children: [
                              // Role Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      DSTokens.spaceS +
                                      DSTokens.spaceXS, // 10px
                                  vertical: DSTokens.spaceXS + 1, // 5px
                                ),
                                decoration: BoxDecoration(
                                  color: DSColors.textOnColor.withValues(
                                    alpha: 0.95,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    DSTokens.radiusM,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: DSColors.black.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: DSTokens.spaceXS,
                                      offset: const Offset(
                                        0,
                                        DSTokens.spaceXS / 2,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getRoleIcon(currentUser.role),
                                      size: DSTokens.fontS - 1, // 11px
                                      color: _getRoleColor(currentUser.role),
                                    ),
                                    const SizedBox(
                                      width: DSTokens.spaceXXS + 1,
                                    ), // 3px
                                    Text(
                                      currentUser.role.value.toUpperCase(),
                                      style: DSTypography.labelSmall.copyWith(
                                        color: _getRoleColor(currentUser.role),
                                        fontWeight: DSTokens.fontWeightBold,
                                        letterSpacing: 0.6,
                                        fontSize: DSTokens.fontXS + 1, // 9px
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Status Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal:
                                      DSTokens.spaceS +
                                      DSTokens.spaceXS, // 10px
                                  vertical: DSTokens.spaceXS + 1, // 5px
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    currentUser.status,
                                  ).withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(
                                    DSTokens.radiusM,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getStatusColor(
                                        currentUser.status,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: DSTokens.spaceXS,
                                      offset: const Offset(
                                        0,
                                        DSTokens.spaceXS / 2,
                                      ),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStatusIcon(currentUser.status),
                                      size: DSTokens.fontS - 1, // 11px
                                      color: DSColors.textOnColor,
                                    ),
                                    const SizedBox(
                                      width: DSTokens.spaceXXS + 1,
                                    ), // 3px
                                    Text(
                                      currentUser.status.value.toUpperCase(),
                                      style: DSTypography.labelSmall.copyWith(
                                        color: DSColors.textOnColor,
                                        fontWeight: DSTokens.fontWeightBold,
                                        letterSpacing: 0.6,
                                        fontSize: DSTokens.fontXS + 1, // 9px
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: DSTokens.spaceM),

                          // Email with enhanced styling
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: DSTokens.spaceXXS,
                              vertical: DSTokens.spaceXS / 2,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  currentUser.email,
                                  style: DSTypography.bodyMedium.copyWith(
                                    color: DSColors.textOnColor.withValues(
                                      alpha: 0.9,
                                    ),
                                    letterSpacing: 0.3,
                                    fontWeight: DSTokens.fontWeightRegular,
                                    height: 1.2,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (onTap != null) ...[
                                  const SizedBox(height: DSTokens.spaceXS),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.touch_app_rounded,
                                        size: DSTokens.fontS,
                                        color: DSColors.textOnColor.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: DSTokens.spaceXS / 2,
                                      ),
                                      Text(
                                        'Tap for details',
                                        style: DSTypography.bodySmall.copyWith(
                                          color: DSColors.textOnColor
                                              .withValues(alpha: 0.7),
                                          fontSize: DSTokens.fontS,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
