import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../core/errors/failures.dart';
import '../../../../domain/entities/user.dart';

enum UserStatusFilter { all, verified, unverified, suspended }

class UserStatsCard extends ConsumerWidget {
  final List<User> users;
  final UserStatusFilter? selectedFilter;
  final Function(UserStatusFilter)? onFilterChanged;

  const UserStatsCard({
    super.key,
    required this.users,
    this.selectedFilter,
    this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = _calculateStats();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceL,
        vertical: DSTokens.spaceM,
      ),
      child: Row(
        children: [
          // Total users card
          Expanded(
            child: _buildStatCard(
              context,
              'Total',
              stats.total,
              Icons.people_outline,
              DSColors.brandPrimary,
              UserStatusFilter.all,
              selectedFilter == UserStatusFilter.all,
            ),
          ),
          const SizedBox(width: DSTokens.spaceM),

          // Verified users card
          Expanded(
            child: _buildStatCard(
              context,
              'Verified',
              stats.verified,
              Icons.verified_outlined,
              DSColors.success,
              UserStatusFilter.verified,
              selectedFilter == UserStatusFilter.verified,
            ),
          ),
          const SizedBox(width: DSTokens.spaceM),

          // Unverified users card
          Expanded(
            child: _buildStatCard(
              context,
              'Unverified',
              stats.unverified,
              Icons.pending_outlined,
              DSColors.warning,
              UserStatusFilter.unverified,
              selectedFilter == UserStatusFilter.unverified,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    int count,
    IconData icon,
    Color color,
    UserStatusFilter filter,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onFilterChanged != null ? () => onFilterChanged!(filter) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(DSTokens.spaceL),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.15 : 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          border: Border.all(
            color: isSelected
                ? color
                : (isDark ? DSColors.neutral700 : DSColors.neutral200),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? color.withValues(alpha: isDark ? 0.3 : 0.1)
                  : (isDark
                        ? DSColors.black.withValues(alpha: 0.2)
                        : DSColors.black.withValues(alpha: 0.02)),
              blurRadius: isSelected ? 6 : (isDark ? 2 : 4),
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Simple icon
            Container(
              padding: const EdgeInsets.all(DSTokens.spaceS),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isDark ? 0.15 : 0.1),
                borderRadius: BorderRadius.circular(DSTokens.spaceS),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: DSTokens.spaceM),

            // Count with animated appearance
            TweenAnimationBuilder<int>(
              duration: const Duration(milliseconds: 800),
              tween: IntTween(begin: 0, end: count),
              curve: Curves.easeOutCubic,
              builder: (context, animatedCount, child) {
                return Text(
                  animatedCount.toString(),
                  style: DSTypography.headlineLarge.copyWith(
                    color: isSelected ? color : colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                );
              },
            ),
            const SizedBox(height: DSTokens.spaceXS),

            // Title below count (centered, no subtitle)
            Text(
              label,
              style: DSTypography.labelMedium.copyWith(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  UserStats _calculateStats() {
    int verified = 0;
    int unverified = 0;
    int suspended = 0;

    for (final user in users) {
      switch (user.status) {
        case UserStatus.verified:
          verified++;
          break;
        case UserStatus.unverified:
          unverified++;
          break;
        case UserStatus.suspended:
          suspended++;
          break;
      }
    }

    return UserStats(
      verified: verified,
      unverified: unverified,
      suspended: suspended,
    );
  }
}

class UserStats {
  final int verified;
  final int unverified;
  final int suspended;

  const UserStats({
    required this.verified,
    required this.unverified,
    required this.suspended,
  });

  int get total => verified + unverified + suspended;
}
