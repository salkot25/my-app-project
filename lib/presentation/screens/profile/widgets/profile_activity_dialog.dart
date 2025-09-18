import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';
import 'profile_activity.dart';

class ProfileActivityDialog extends ConsumerWidget {
  final User currentUser;

  const ProfileActivityDialog({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(DSTokens.radiusXL),
          topRight: Radius.circular(DSTokens.radiusXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: DSTokens.spaceS),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: ref.colors.textTertiary.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(DSTokens.spaceL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DSTokens.spaceS),
                  decoration: BoxDecoration(
                    color: DSColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSTokens.radiusM),
                  ),
                  child: Icon(
                    Icons.timeline_rounded,
                    color: DSColors.info,
                    size: DSTokens.fontL,
                  ),
                ),
                const SizedBox(width: DSTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: DSTypography.headlineSmall.copyWith(
                          color: ref.colors.textPrimary,
                          fontWeight: DSTokens.fontWeightBold,
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
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close_rounded,
                    color: ref.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Activity Content
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  DSTokens.spaceL,
                  0,
                  DSTokens.spaceL,
                  DSTokens.spaceL,
                ),
                child: ProfileActivity(
                  currentUser: currentUser,
                  showBackground: false,
                ),
              ),
            ),
          ),

          // Safe area bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
