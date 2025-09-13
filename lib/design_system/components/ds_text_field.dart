import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Text field component with consistent styling and validation
/// Follows Material Design 3 guidelines
class DSTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const DSTextField({
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.onChanged,
    this.onTap,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    super.key,
  });

  @override
  State<DSTextField> createState() => _DSTextFieldState();
}

class _DSTextFieldState extends State<DSTextField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasError = widget.errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: DSTypography.labelMedium.copyWith(
              color: hasError ? DSColors.error : null,
            ),
          ),
          const SizedBox(height: DSTokens.spaceXS),
        ],
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          onChanged: widget.onChanged,
          onTap: widget.onTap,
          validator: widget.validator,
          obscureText: widget.obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          style: DSTypography.bodyMedium,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: DSTypography.bodyMedium.copyWith(
              color: DSColors.textTertiary,
            ),
            prefixIcon: widget.prefixIcon,
            suffixIcon: widget.suffixIcon,
            filled: true,
            fillColor: widget.enabled
                ? (hasError ? DSColors.error.withValues(alpha: 0.05) : null)
                : DSColors.primary50,
            border: _buildBorder(colorScheme.outline),
            enabledBorder: _buildBorder(
              hasError ? DSColors.error : colorScheme.outline,
            ),
            focusedBorder: _buildBorder(
              hasError ? DSColors.error : colorScheme.primary,
              width: 2,
            ),
            errorBorder: _buildBorder(DSColors.error),
            focusedErrorBorder: _buildBorder(DSColors.error, width: 2),
            disabledBorder: _buildBorder(DSColors.primary200),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceM,
              vertical: DSTokens.spaceM,
            ),
            counterStyle: DSTypography.caption,
          ),
        ),
        if (widget.errorText != null || widget.helperText != null) ...[
          const SizedBox(height: DSTokens.spaceXS),
          Text(
            widget.errorText ?? widget.helperText!,
            style: DSTypography.caption.copyWith(
              color: hasError ? DSColors.error : DSColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(DSTokens.radiusM),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
