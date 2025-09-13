import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/colors.dart';
import '../tokens/typography.dart';

/// Avatar component with multiple variants and accessibility
class Avatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool showBorder;
  final Widget? badge;

  const Avatar({
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.onTap,
    this.showBorder = false,
    this.badge,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: showBorder
                  ? Border.all(color: DSColors.border, width: 2)
                  : null,
              color: backgroundColor ?? DSColors.brandPrimary100,
            ),
            child: ClipOval(
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      width: size,
                      height: size,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildInitials(),
                    )
                  : _buildInitials(),
            ),
          ),
          if (badge != null) Positioned(right: 0, bottom: 0, child: badge!),
        ],
      ),
    );
  }

  Widget _buildInitials() {
    final initials =
        name
            ?.split(' ')
            .take(2)
            .map((word) => word.isNotEmpty ? word[0].toUpperCase() : '')
            .join('') ??
        '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? DSColors.brandPrimary,
      ),
      child: Center(
        child: Text(
          initials,
          style: DSTypography.buttonMedium.copyWith(
            fontSize: size * 0.4,
            color: DSColors.textOnColor,
          ),
        ),
      ),
    );
  }
}

/// Badge component for notifications and status
class Badge extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final Color? textColor;
  final BadgeVariant variant;
  final BadgeSize size;

  const Badge({
    this.text,
    this.backgroundColor,
    this.textColor,
    this.variant = BadgeVariant.primary,
    this.size = BadgeSize.medium,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final (bgColor, fgColor) = _getColors();
    final padding = _getPadding();
    final textStyle = _getTextStyle();

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? bgColor,
        borderRadius: BorderRadius.circular(DSTokens.radiusCircle),
      ),
      child: text != null
          ? Text(text!, style: textStyle.copyWith(color: textColor ?? fgColor))
          : null,
    );
  }

  (Color, Color) _getColors() {
    switch (variant) {
      case BadgeVariant.primary:
        return (DSColors.brandPrimary, DSColors.textOnColor);
      case BadgeVariant.success:
        return (DSColors.success, DSColors.textOnColor);
      case BadgeVariant.warning:
        return (DSColors.warning, DSColors.textOnColor);
      case BadgeVariant.error:
        return (DSColors.error, DSColors.textOnColor);
      case BadgeVariant.neutral:
        return (DSColors.surfaceContainer, DSColors.textSecondary);
    }
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case BadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BadgeSize.medium:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
      case BadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case BadgeSize.small:
        return DSTypography.bodySmall;
      case BadgeSize.medium:
        return DSTypography.bodyMedium;
      case BadgeSize.large:
        return DSTypography.bodyLarge;
    }
  }
}

enum BadgeVariant { primary, success, warning, error, neutral }

enum BadgeSize { small, medium, large }

/// Tooltip component for contextual help
class DSTooltip extends StatelessWidget {
  final Widget child;
  final String message;
  final TooltipPosition position;

  const DSTooltip({
    required this.child,
    required this.message,
    this.position = TooltipPosition.top,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: DSColors.darkSurface,
        borderRadius: BorderRadius.circular(DSTokens.radiusS),
      ),
      textStyle: DSTypography.bodySmall.copyWith(color: DSColors.textOnColor),
      padding: const EdgeInsets.symmetric(
        horizontal: DSTokens.spaceS,
        vertical: DSTokens.spaceXS,
      ),
      child: child,
    );
  }
}

enum TooltipPosition { top, bottom, left, right }
