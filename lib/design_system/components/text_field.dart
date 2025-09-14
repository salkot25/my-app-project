import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Minimalist text field component with borderless design and clean focus states
/// Follows minimalist modern principles with underline focus instead of borders
class CustomTextField extends StatefulWidget {
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
  final bool isMinimalist; // NEW: Toggle for minimalist mode

  const CustomTextField({
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
    this.isMinimalist = true, // Default to minimalist mode
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
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

            // MINIMALIST DESIGN: Clean background handling
            filled: widget.isMinimalist
                ? false
                : true, // No fill for minimalist
            fillColor: widget.isMinimalist
                ? Colors.transparent
                : widget.enabled
                ? (hasError ? DSColors.error.withValues(alpha: 0.05) : null)
                : DSColors.primary50,

            // MINIMALIST BORDERS: Clean underline design instead of outlines
            border: widget.isMinimalist
                ? _buildMinimalistBorder(
                    DSColors.textTertiary.withValues(alpha: 0.3),
                  )
                : _buildBorder(colorScheme.outline),
            enabledBorder: widget.isMinimalist
                ? _buildMinimalistBorder(
                    hasError
                        ? DSColors.error
                        : DSColors.textTertiary.withValues(alpha: 0.2),
                  )
                : _buildBorder(hasError ? DSColors.error : colorScheme.outline),
            focusedBorder: widget.isMinimalist
                ? _buildMinimalistBorder(
                    hasError ? DSColors.error : colorScheme.primary,
                    width: 2,
                  )
                : _buildBorder(
                    hasError ? DSColors.error : colorScheme.primary,
                    width: 2,
                  ),
            errorBorder: widget.isMinimalist
                ? _buildMinimalistBorder(DSColors.error)
                : _buildBorder(DSColors.error),
            focusedErrorBorder: widget.isMinimalist
                ? _buildMinimalistBorder(DSColors.error, width: 2)
                : _buildBorder(DSColors.error, width: 2),
            disabledBorder: widget.isMinimalist
                ? _buildMinimalistBorder(
                    DSColors.primary200.withValues(alpha: 0.1),
                  )
                : _buildBorder(DSColors.primary200),

            // MINIMALIST PADDING: More generous spacing
            contentPadding: EdgeInsets.symmetric(
              horizontal: widget.isMinimalist
                  ? 0
                  : DSTokens.spaceM, // No horizontal padding for minimalist
              vertical: DSTokens.spaceL, // More vertical breathing room
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

  /// MINIMALIST BORDER: Clean underline instead of full border
  UnderlineInputBorder _buildMinimalistBorder(Color color, {double width = 1}) {
    return UnderlineInputBorder(
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
