import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class AuthTextField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool isPassword;
  final bool? isPasswordVisible;
  final VoidCallback? onTogglePasswordVisibility;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.keyboardType,
    this.validator,
    this.isPassword = false,
    this.isPasswordVisible,
    this.onTogglePasswordVisibility,
  });

  @override
  ConsumerState<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends ConsumerState<AuthTextField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword && !(widget.isPasswordVisible ?? false),
      style: DSTypography.bodyLarge.copyWith(color: ref.colors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: DSTypography.labelMedium.copyWith(
          color: ref.colors.textSecondary,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: ref.colors.textSecondary,
          size: DSTokens.fontL + DSTokens.spaceXS, // 22px
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: widget.onTogglePasswordVisibility,
                icon: Icon(
                  (widget.isPasswordVisible ?? false)
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: ref.colors.textSecondary,
                  size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          borderSide: BorderSide(color: ref.colors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          borderSide: BorderSide(color: ref.colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          borderSide: BorderSide(
            color: DSColors.brandPrimary,
            width: DSTokens.spaceXS / 2, // 2px
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          borderSide: BorderSide(
            color: DSColors.error,
            width: DSTokens.spaceXXS / 2, // 1px
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          borderSide: BorderSide(
            color: DSColors.error,
            width: DSTokens.spaceXS / 2, // 2px
          ),
        ),
        filled: true,
        fillColor: ref.colors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: DSTokens.spaceM,
          vertical: DSTokens.spaceM,
        ),
      ),
      validator: widget.validator,
    );
  }
}
