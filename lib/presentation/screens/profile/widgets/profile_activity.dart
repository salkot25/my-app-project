import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';
import '../../../../design_system/utils/status_utils.dart';

class ProfileActivity extends ConsumerWidget {
  final User currentUser;
  final bool showBackground;

  const ProfileActivity({
    super.key,
    required this.currentUser,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [_buildActivityList(ref)],
    );

    if (showBackground) {
      return Container(
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
          border: Border.all(color: ref.colors.border),
          boxShadow: [
            BoxShadow(
              color: ref.colors.shadowColor.withValues(alpha: 0.1),
              blurRadius: DSTokens.spaceS,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildHeader(ref), content],
        ),
      );
    }

    return content;
  }

  Widget _buildDivider(WidgetRef ref) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: DSTokens.spaceS),
      color: ref.colors.border.withValues(alpha: 0.3),
    );
  }

  Widget _buildSectionDivider(WidgetRef ref) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: DSTokens.spaceM),
      color: ref.colors.border,
    );
  }

  Widget _buildHeader(WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(DSTokens.spaceL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: DSTypography.headlineSmall.copyWith(
              color: ref.colors.textPrimary,
              fontWeight: DSTokens.fontWeightMedium,
            ),
          ),
          const SizedBox(height: DSTokens.spaceXXS),
          Text(
            'Your account activity and updates',
            style: DSTypography.bodySmall.copyWith(
              color: ref.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList(WidgetRef ref) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        DSTokens.spaceL,
        showBackground ? 0 : DSTokens.spaceL,
        DSTokens.spaceL,
        DSTokens.spaceL,
      ),
      child: Column(
        children: [
          _buildActivityItem(
            ref: ref,
            icon: Icons.person_add_rounded,
            title: 'Account Created',
            description: 'Welcome to the platform!',
            timestamp: currentUser.createdAt,
            color: DSColors.success,
          ),
          _buildDivider(ref),
          if (currentUser.updatedAt != currentUser.createdAt) ...[
            _buildActivityItem(
              ref: ref,
              icon: Icons.edit_rounded,
              title: 'Profile Updated',
              description: 'Your profile information was updated',
              timestamp: currentUser.updatedAt,
              color: DSColors.info,
            ),
            _buildDivider(ref),
          ],
          _buildActivityItem(
            ref: ref,
            icon: Icons.login_rounded,
            title: 'Current Session',
            description: 'You are currently logged in',
            timestamp: DateTime.now(),
            color: DSColors.warning,
            isCurrentSession: true,
          ),
          _buildSectionDivider(ref),
          _buildAccountStatistics(ref),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String description,
    required DateTime timestamp,
    required Color color,
    bool isCurrentSession = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DSTokens.spaceXS),
      child: Row(
        children: [
          // Minimal icon without background container
          Icon(icon, color: color, size: DSTokens.fontL),
          const SizedBox(width: DSTokens.spaceM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: DSTypography.bodyLarge.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightMedium,
                        ),
                      ),
                    ),
                    if (isCurrentSession)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DSTokens.spaceXS,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: DSColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            DSTokens.radiusXS,
                          ),
                        ),
                        child: Text(
                          'ACTIVE',
                          style: DSTypography.labelSmall.copyWith(
                            color: DSColors.success,
                            fontWeight: DSTokens.fontWeightBold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: DSTypography.bodySmall.copyWith(
                    color: ref.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(timestamp, isCurrentSession),
                  style: DSTypography.labelSmall.copyWith(
                    color: ref.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStatistics(WidgetRef ref) {
    final accountAge = DateTime.now().difference(currentUser.createdAt).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title untuk statistics
        Text(
          'Account Overview',
          style: DSTypography.labelLarge.copyWith(
            color: ref.colors.textPrimary,
            fontWeight: DSTokens.fontWeightSemiBold,
          ),
        ),
        const SizedBox(height: DSTokens.spaceM),

        // Minimal statistics without container background
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                ref: ref,
                label: 'Account Age',
                value: '$accountAge days',
              ),
            ),
            // Vertical divider between stat items
            Container(
              width: 1,
              height: DSTokens.spaceL,
              margin: const EdgeInsets.symmetric(horizontal: DSTokens.spaceS),
              color: ref.colors.border.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _buildStatItem(
                ref: ref,
                label: 'Status',
                value: currentUser.status.value,
                valueColor: StatusUtils.getStatusColor(currentUser.status),
              ),
            ),
          ],
        ),
        const SizedBox(height: DSTokens.spaceS),
        Row(
          children: [
            Expanded(
              child: _buildStatItem(
                ref: ref,
                label: 'Role',
                value: currentUser.role.value,
                valueColor: _getRoleColor(currentUser.role.value),
              ),
            ),
            // Vertical divider between stat items
            Container(
              width: 1,
              height: DSTokens.spaceL,
              margin: const EdgeInsets.symmetric(horizontal: DSTokens.spaceS),
              color: ref.colors.border.withValues(alpha: 0.3),
            ),
            Expanded(
              child: _buildStatItem(
                ref: ref,
                label: 'Member Since',
                value: _formatDate(currentUser.createdAt),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required WidgetRef ref,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: DSTypography.labelSmall.copyWith(
            color: ref.colors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: DSTypography.bodyMedium.copyWith(
            color: valueColor ?? ref.colors.textPrimary,
            fontWeight: DSTokens.fontWeightSemiBold,
          ),
        ),
      ],
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return DSColors.error;
      case 'moderator':
        return DSColors.warning;
      case 'user':
      default:
        return DSColors.info;
    }
  }

  String _formatTimestamp(DateTime timestamp, bool isCurrentSession) {
    if (isCurrentSession) {
      return 'Right now';
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 30) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }
}
