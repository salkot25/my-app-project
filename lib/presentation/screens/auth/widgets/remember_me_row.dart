import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class RememberMeRow extends ConsumerWidget {
  final bool rememberMe;
  final ValueChanged<bool> onRememberMeChanged;
  final VoidCallback onForgotPasswordTap;

  const RememberMeRow({
    super.key,
    required this.rememberMe,
    required this.onRememberMeChanged,
    required this.onForgotPasswordTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Remember Me Checkbox
        Expanded(
          child: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: Checkbox(
                  value: rememberMe,
                  onChanged: (value) => onRememberMeChanged(value ?? false),
                  activeColor: DSColors.brandPrimary,
                  checkColor: DSColors.textOnColor,
                  side: BorderSide(color: ref.colors.border, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: DSTokens.spaceS),
              Text(
                'Remember me',
                style: DSTypography.bodySmall.copyWith(
                  color: ref.colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        // Forgot Password Link
        TextButton(
          onPressed: onForgotPasswordTap,
          style: TextButton.styleFrom(
            foregroundColor: DSColors.brandPrimary,
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceS,
              vertical: DSTokens.spaceXS,
            ),
          ),
          child: Text(
            'Forgot Password?',
            style: DSTypography.labelMedium.copyWith(
              color: DSColors.brandPrimary,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }
}
