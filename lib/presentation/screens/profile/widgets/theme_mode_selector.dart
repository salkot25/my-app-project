import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/failures.dart';
import '../../../../design_system/design_system.dart';
import '../../../../domain/entities/user.dart';

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
        onTap: () => _showThemeDialog(context, ref),
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

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.read(themeModeProvider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: ref.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusL),
        ),
        title: Text(
          'Choose Theme',
          style: DSTypography.headlineSmall.copyWith(
            color: ref.colors.textPrimary,
            fontWeight: DSTokens.fontWeightBold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppThemeMode.values.map((themeMode) {
            final isSelected = currentTheme == themeMode;
            return _buildThemeOption(context, ref, themeMode, isSelected);
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _getRoleColor(currentUser.role),
            ),
            child: Text('Close', style: DSTypography.buttonMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    AppThemeMode themeMode,
    bool isSelected,
  ) {
    return Material(
      color: DSColors.transparent,
      child: InkWell(
        onTap: () async {
          await ref.read(themeProvider.notifier).setThemeMode(themeMode);
          if (context.mounted) {
            Navigator.of(context).pop();

            // Show feedback
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Theme changed to ${themeMode.displayName}',
                  style: DSTypography.bodyMedium.copyWith(
                    color: DSColors.textOnColor,
                  ),
                ),
                backgroundColor: _getRoleColor(currentUser.role),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSTokens.radiusM),
                ),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DSTokens.spaceM,
            vertical: DSTokens.spaceS,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSTokens.spaceXS),
                decoration: BoxDecoration(
                  color: isSelected
                      ? _getRoleColor(currentUser.role).withValues(alpha: 0.1)
                      : ref.colors.textSecondary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(DSTokens.spaceXS),
                ),
                child: Icon(
                  themeMode.icon,
                  color: isSelected
                      ? _getRoleColor(currentUser.role)
                      : ref.colors.textSecondary,
                  size: DSTokens.fontM,
                ),
              ),
              const SizedBox(width: DSTokens.spaceM),
              Expanded(
                child: Text(
                  themeMode.displayName,
                  style: DSTypography.bodyMedium.copyWith(
                    color: isSelected
                        ? _getRoleColor(currentUser.role)
                        : ref.colors.textPrimary,
                    fontWeight: isSelected
                        ? DSTokens.fontWeightSemiBold
                        : DSTokens.fontWeightMedium,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  color: _getRoleColor(currentUser.role),
                  size: DSTokens.fontM,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
