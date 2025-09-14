import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/typography.dart';

/// Minimalist card component with clean styling and subtle shadows
/// Follows minimalist modern design principles - no borders, clean backgrounds
/// Supports different elevations and content layouts
class Card extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool isMinimalist; // NEW: Toggle minimalist mode

  const Card({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.isMinimalist = true, // Default to minimalist mode
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Widget card = Container(
      margin: margin ?? const EdgeInsets.all(DSTokens.spaceS),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: borderRadius ?? BorderRadius.circular(DSTokens.radiusM),
        // MINIMALIST PRINCIPLE: No borders! Use background differentiation instead
        border: isMinimalist
            ? null
            : Border.all(
                color: colorScheme.outline.withValues(
                  alpha: 0.1,
                ), // Very subtle if needed
              ),
        boxShadow: _getMinimalistShadow(),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(DSTokens.radiusM),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius:
                borderRadius ?? BorderRadius.circular(DSTokens.radiusM),
            child: Padding(
              padding:
                  padding ??
                  const EdgeInsets.all(
                    DSTokens.spaceL,
                  ), // More generous padding
              child: child,
            ),
          ),
        ),
      ),
    );

    return card;
  }

  /// Minimalist shadow system - more subtle and clean
  List<BoxShadow>? _getMinimalistShadow() {
    if (elevation == null || elevation! <= 0) return null;

    // MINIMALIST PRINCIPLE: Much more subtle shadows
    if (elevation! <= 2) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04), // Very subtle
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }

    if (elevation! <= 4) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06), // Still very subtle
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }

    if (elevation! <= 8) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08), // Maximum subtlety
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];
    }

    // For higher elevations, keep it clean but visible
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ];
  }
}

/// Specialized card for content with header and optional actions
class ContentCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget content;
  final EdgeInsets? padding;

  const ContentCard({
    required this.content,
    this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.padding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null ||
              subtitle != null ||
              leading != null ||
              actions != null)
            _buildHeader(),
          if (_hasHeader()) const SizedBox(height: DSTokens.spaceM),
          content,
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (leading != null) ...[
          leading!,
          const SizedBox(width: DSTokens.spaceM),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Text(title!, style: DSTypography.headlineSmall),
              if (subtitle != null) ...[
                if (title != null) const SizedBox(height: DSTokens.spaceXS),
                Text(subtitle!, style: DSTypography.bodySmall),
              ],
            ],
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: DSTokens.spaceM),
          ...actions!,
        ],
      ],
    );
  }

  bool _hasHeader() {
    return title != null ||
        subtitle != null ||
        leading != null ||
        actions != null;
  }
}
