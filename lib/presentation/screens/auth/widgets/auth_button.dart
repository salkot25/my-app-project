import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class AuthButton extends ConsumerWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final Color? backgroundColor;
  final double? width;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.backgroundColor,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              backgroundColor ??
              (isSecondary ? Colors.transparent : DSColors.brandPrimary),
          foregroundColor: isSecondary
              ? DSColors.brandPrimary
              : DSColors.textOnColor,
          side: isSecondary
              ? BorderSide(color: DSColors.brandPrimary, width: 1.5)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSTokens.radiusM),
          ),
          elevation: isSecondary ? 0 : 2,
          shadowColor: DSColors.brandPrimary.withValues(alpha: 0.25),
          padding: EdgeInsets.zero,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary ? DSColors.brandPrimary : DSColors.textOnColor,
                  ),
                ),
              )
            : Text(
                text,
                style: DSTypography.labelLarge.copyWith(
                  color: isSecondary
                      ? DSColors.brandPrimary
                      : DSColors.textOnColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
