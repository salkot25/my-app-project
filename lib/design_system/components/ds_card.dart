import 'package:flutter/material.dart';
import '../tokens/tokens.dart';
import '../tokens/typography.dart';

/// Card component with consistent styling and shadows
/// Supports different elevations and content layouts
class DSCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? elevation;
  final BorderRadius? borderRadius;
  final Border? border;

  const DSCard({
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.elevation,
    this.borderRadius,
    this.border,
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
        border: border ?? Border.all(color: colorScheme.outline),
        boxShadow: _getBoxShadow(),
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
              padding: padding ?? const EdgeInsets.all(DSTokens.spaceM),
              child: child,
            ),
          ),
        ),
      ),
    );

    return card;
  }

  List<BoxShadow>? _getBoxShadow() {
    if (elevation == null) return null;

    if (elevation! <= 0) return null;
    if (elevation! <= 2) return [DSTokens.shadowXS];
    if (elevation! <= 4) return [DSTokens.shadowS];
    if (elevation! <= 8) return [DSTokens.shadowM];
    return [DSTokens.shadowL];
  }
}

/// Specialized card for content with header and optional actions
class DSContentCard extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;
  final Widget content;
  final EdgeInsets? padding;

  const DSContentCard({
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
    return DSCard(
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
