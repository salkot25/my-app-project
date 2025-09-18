import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/entities/user_role.dart';

class ThemeModeSelector extends ConsumerWidget {
  final User currentUser;

  const ThemeModeSelector({super.key, required this.currentUser});

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);

    return Material(
      color: DSColors.transparent,
      child: InkWell(
        onTap: () => _showThemeBottomSheet(context, ref),
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
                  color: ref.colors.textSecondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    DSTokens.spaceS + DSTokens.spaceXS,
                  ), // 10px
                ),
                child: Icon(
                  currentTheme.icon,
                  color: ref.colors.textSecondary,
                  size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                ),
              ),
              const SizedBox(width: DSTokens.spaceM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Theme Mode',
                      style: DSTypography.bodyLarge.copyWith(
                        color: ref.colors.textPrimary,
                        fontWeight: DSTokens.fontWeightSemiBold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: DSTokens.spaceXS / 2), // 2px
                    Text(
                      currentTheme.displayName,
                      style: DSTypography.bodySmall.copyWith(
                        color: ref.colors.textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSTokens.spaceM),
              Icon(
                Icons.chevron_right_rounded,
                color: ref.colors.textTertiary,
                size: DSTokens.fontL,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showThemeBottomSheet(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: ref.colors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(DSTokens.radiusL),
            topRight: Radius.circular(DSTokens.radiusL),
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
                      color: _getRoleColor(
                        currentUser.role,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(DSTokens.radiusM),
                    ),
                    child: Icon(
                      Icons.palette_rounded,
                      color: _getRoleColor(currentUser.role),
                      size: DSTokens.fontL,
                    ),
                  ),
                  const SizedBox(width: DSTokens.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Choose Theme',
                          style: DSTypography.headlineSmall.copyWith(
                            color: ref.colors.textPrimary,
                            fontWeight: DSTokens.fontWeightBold,
                          ),
                        ),
                        Text(
                          'Select your preferred theme mode',
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

            // Theme options
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSTokens.spaceL,
                0,
                DSTokens.spaceL,
                DSTokens.spaceL,
              ),
              child: Column(
                children: AppThemeMode.values.map((themeMode) {
                  final isSelected = currentTheme == themeMode;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: DSTokens.spaceS),
                    child: _buildThemeOption(
                      context,
                      ref,
                      themeMode,
                      isSelected,
                    ),
                  );
                }).toList(),
              ),
            ),

            // Safe area bottom padding
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode themeMode,
    bool isSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? _getRoleColor(currentUser.role).withValues(alpha: 0.1)
            : ref.colors.surfaceContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(
          color: isSelected
              ? _getRoleColor(currentUser.role).withValues(alpha: 0.3)
              : ref.colors.border,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await ref.read(themeProvider.notifier).setThemeMode(themeMode);
            if (context.mounted) {
              Navigator.of(context).pop();

              // Show feedback
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.check_rounded,
                        color: DSColors.textOnColor,
                        size: DSTokens.fontM,
                      ),
                      const SizedBox(width: DSTokens.spaceS),
                      Text(
                        'Theme changed to ${themeMode.displayName}',
                        style: DSTypography.bodyMedium.copyWith(
                          color: DSColors.textOnColor,
                          fontWeight: DSTokens.fontWeightMedium,
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: _getRoleColor(currentUser.role),
                  behavior: SnackBarBehavior.floating,
                  margin: const EdgeInsets.all(DSTokens.spaceM),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(DSTokens.radiusM),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
          child: Padding(
            padding: const EdgeInsets.all(DSTokens.spaceL),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(DSTokens.spaceS),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getRoleColor(currentUser.role).withValues(alpha: 0.2)
                        : ref.colors.textSecondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DSTokens.radiusM),
                  ),
                  child: Icon(
                    themeMode.icon,
                    color: isSelected
                        ? _getRoleColor(currentUser.role)
                        : ref.colors.textSecondary,
                    size: DSTokens.fontL,
                  ),
                ),
                const SizedBox(width: DSTokens.spaceM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        themeMode.displayName,
                        style: DSTypography.bodyLarge.copyWith(
                          color: isSelected
                              ? _getRoleColor(currentUser.role)
                              : ref.colors.textPrimary,
                          fontWeight: isSelected
                              ? DSTokens.fontWeightBold
                              : DSTokens.fontWeightSemiBold,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: DSTokens.spaceXS / 2),
                      Text(
                        _getThemeDescription(themeMode),
                        style: DSTypography.bodySmall.copyWith(
                          color: ref.colors.textSecondary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: DSTokens.spaceM),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(DSTokens.spaceXS),
                    decoration: BoxDecoration(
                      color: _getRoleColor(currentUser.role),
                      borderRadius: BorderRadius.circular(DSTokens.radiusS),
                    ),
                    child: Icon(
                      Icons.check_rounded,
                      color: DSColors.textOnColor,
                      size: DSTokens.fontM,
                    ),
                  )
                else
                  Container(
                    width: DSTokens.fontL + (DSTokens.spaceXS * 2),
                    height: DSTokens.fontL + (DSTokens.spaceXS * 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: ref.colors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(DSTokens.radiusS),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getThemeDescription(AppThemeMode themeMode) {
    switch (themeMode) {
      case AppThemeMode.light:
        return 'Always use light theme';
      case AppThemeMode.dark:
        return 'Always use dark theme';
      case AppThemeMode.system:
        return 'Follow system settings';
    }
  }
}
