import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';
import '../utils/animations.dart';

/// Button variants following the Single Responsibility Principle
enum DSButtonVariant { primary, secondary, tertiary, danger, success }

/// Button sizes for consistent spacing
enum DSButtonSize { small, medium, large }

/// Enhanced button component with accessibility and micro-interactions
/// Supports multiple variants, sizes, and states following SOLID principles
class DSButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final DSButtonVariant variant;
  final DSButtonSize size;
  final bool isLoading;
  final bool isDisabled;
  final Widget? icon;
  final Widget? trailingIcon;
  final bool fullWidth;
  final String? tooltip;
  final String? semanticLabel;

  const DSButton({
    required this.label,
    this.onPressed,
    this.variant = DSButtonVariant.primary,
    this.size = DSButtonSize.medium,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
    this.trailingIcon,
    this.fullWidth = false,
    this.tooltip,
    this.semanticLabel,
    super.key,
  });

  @override
  State<DSButton> createState() => _DSButtonState();
}

class _DSButtonState extends State<DSButton> {
  bool _isHovered = false;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final isEffectivelyDisabled = widget.isDisabled || widget.onPressed == null;
    final buttonChild = _buildButtonChild();

    Widget button = Focus(
      onFocusChange: (focused) => setState(() => _isFocused = focused),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: DSAnimatedButton(
          onPressed: widget.isLoading || isEffectivelyDisabled
              ? null
              : () {
                  HapticFeedback.lightImpact(); // Tactile feedback
                  widget.onPressed?.call();
                },
          child: Container(
            decoration: BoxDecoration(
              gradient: _getGradient(),
              borderRadius: BorderRadius.circular(_getBorderRadius()),
              border: _getBorder(),
              boxShadow: _getBoxShadow(),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(_getBorderRadius()),
                onTap: widget.isLoading || isEffectivelyDisabled
                    ? null
                    : widget.onPressed,
                child: Container(padding: _getPadding(), child: buttonChild),
              ),
            ),
          ),
        ),
      ),
    );

    // Add semantic label for accessibility
    if (widget.semanticLabel != null) {
      button = Semantics(
        label: widget.semanticLabel,
        button: true,
        enabled: !isEffectivelyDisabled,
        child: button,
      );
    }

    // Add tooltip if provided
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }

    // Full width wrapper
    if (widget.fullWidth) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return DSAnimations.fadeIn(child: button);
  }

  (Color?, Color?, Color?) _getColors() {
    if (widget.isDisabled || widget.onPressed == null) {
      return (DSColors.interactiveDisabled, DSColors.textDisabled, null);
    }

    final baseColors = switch (widget.variant) {
      DSButtonVariant.primary => (
        DSColors.brandPrimary,
        DSColors.textOnColor,
        null,
      ),
      DSButtonVariant.secondary => (
        Colors.transparent,
        DSColors.brandPrimary,
        DSColors.brandPrimary,
      ),
      DSButtonVariant.tertiary => (
        Colors.transparent,
        DSColors.brandPrimary,
        null,
      ),
      DSButtonVariant.danger => (DSColors.error, DSColors.textOnColor, null),
      DSButtonVariant.success => (DSColors.success, DSColors.textOnColor, null),
    };

    // Apply hover/focus states
    if (_isHovered || _isFocused) {
      return (
        _adjustColorBrightness(baseColors.$1, _isHovered ? -0.1 : -0.05),
        baseColors.$2,
        baseColors.$3 != null
            ? _adjustColorBrightness(baseColors.$3!, -0.1)
            : null,
      );
    }

    return baseColors;
  }

  Color _adjustColorBrightness(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Gradient? _getGradient() {
    if (widget.variant != DSButtonVariant.primary) return null;

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [DSColors.brandPrimary, DSColors.brandSecondary],
    );
  }

  Border? _getBorder() {
    final (_, _, borderColor) = _getColors();
    if (borderColor == null) return null;

    return Border.all(color: borderColor, width: _getBorderWidth());
  }

  double _getBorderWidth() {
    return _isFocused ? 2.0 : 1.0;
  }

  List<BoxShadow>? _getBoxShadow() {
    if (widget.isDisabled || widget.variant == DSButtonVariant.tertiary) {
      return null;
    }

    if (_isHovered) {
      return [
        BoxShadow(
          color: DSColors.brandPrimary.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];
    }

    return [DSTokens.shadowS];
  }

  EdgeInsets _getPadding() {
    return switch (widget.size) {
      DSButtonSize.small => const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceM,
        vertical: DSTokens.spaceS,
      ),
      DSButtonSize.medium => const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceL,
        vertical: DSTokens.spaceM,
      ),
      DSButtonSize.large => const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceXL,
        vertical: DSTokens.spaceL,
      ),
    };
  }

  double _getBorderRadius() {
    return switch (widget.size) {
      DSButtonSize.small => DSTokens.radiusS,
      DSButtonSize.medium => DSTokens.radiusM,
      DSButtonSize.large => DSTokens.radiusL,
    };
  }

  TextStyle _getTextStyle() {
    return switch (widget.size) {
      DSButtonSize.small => DSTypography.buttonMedium,
      DSButtonSize.medium => DSTypography.buttonLarge,
      DSButtonSize.large => DSTypography.headlineMedium,
    };
  }

  Widget _buildButtonChild() {
    if (widget.isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getColors().$2 ?? DSColors.textOnColor,
          ),
        ),
      );
    }

    final children = <Widget>[];

    // Leading icon
    if (widget.icon != null) {
      children.add(
        SizedBox(
          height: _getIconSize(),
          width: _getIconSize(),
          child: widget.icon,
        ),
      );
      children.add(const SizedBox(width: DSTokens.spaceS));
    }

    // Label
    children.add(
      Text(
        widget.label,
        style: _getTextStyle().copyWith(color: _getColors().$2),
      ),
    );

    // Trailing icon
    if (widget.trailingIcon != null) {
      children.add(const SizedBox(width: DSTokens.spaceS));
      children.add(
        SizedBox(
          height: _getIconSize(),
          width: _getIconSize(),
          child: widget.trailingIcon,
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  double _getIconSize() {
    return switch (widget.size) {
      DSButtonSize.small => 16,
      DSButtonSize.medium => 20,
      DSButtonSize.large => 24,
    };
  }
}
