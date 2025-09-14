import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class ProgressiveAuthFeatures extends ConsumerWidget {
  final VoidCallback? onGoogleSignIn;
  final VoidCallback? onAppleSignIn;
  final VoidCallback onCreateAccount;
  final bool showDivider;

  const ProgressiveAuthFeatures({
    super.key,
    this.onGoogleSignIn,
    this.onAppleSignIn,
    required this.onCreateAccount,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        if (showDivider) ...[
          const SizedBox(height: DSTokens.spaceL),
          // OR Divider
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ref.colors.border.withOpacity(0.0),
                        ref.colors.border,
                        ref.colors.border.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSTokens.spaceM,
                ),
                child: Text(
                  'or',
                  style: DSTypography.labelSmall.copyWith(
                    color: ref.colors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ref.colors.border.withOpacity(0.0),
                        ref.colors.border,
                        ref.colors.border.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSTokens.spaceL),
        ],

        // Social Sign-in Buttons
        if (onGoogleSignIn != null || onAppleSignIn != null) ...[
          Row(
            children: [
              if (onGoogleSignIn != null)
                Expanded(
                  child: _SocialButton(
                    onPressed: onGoogleSignIn!,
                    icon: Icons.g_mobiledata,
                    label: 'Google',
                    color: const Color(0xFF4285F4),
                  ),
                ),
              if (onGoogleSignIn != null && onAppleSignIn != null)
                const SizedBox(width: DSTokens.spaceM),
              if (onAppleSignIn != null)
                Expanded(
                  child: _SocialButton(
                    onPressed: onAppleSignIn!,
                    icon: Icons.apple,
                    label: 'Apple',
                    color: ref.colors.textPrimary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSTokens.spaceL),
        ],

        // Create Account Link
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account? ",
              style: DSTypography.bodySmall.copyWith(
                color: ref.colors.textSecondary,
              ),
            ),
            TextButton(
              onPressed: onCreateAccount,
              style: TextButton.styleFrom(
                foregroundColor: DSColors.brandPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: DSTokens.spaceXS,
                ),
              ),
              child: Text(
                'Sign up',
                style: DSTypography.labelMedium.copyWith(
                  color: DSColors.brandPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends ConsumerWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final String label;
  final Color color;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: ref.colors.textPrimary,
        side: BorderSide(color: ref.colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: DSTokens.spaceM,
          horizontal: DSTokens.spaceS,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: DSTokens.spaceXS),
          Text(
            label,
            style: DSTypography.labelMedium.copyWith(
              color: ref.colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
