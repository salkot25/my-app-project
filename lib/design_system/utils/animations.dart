import 'package:flutter/material.dart';
import '../tokens/tokens.dart';

/// Animation system untuk micro-interactions dan transitions
class DSAnimations {
  DSAnimations._();

  // Easing Curves - Brand personality
  static const Curve easeInOut = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve bounce = Curves.elasticOut;
  static const Curve spring = Curves.elasticInOut;

  // Duration presets
  static const Duration instant = Duration.zero;
  static const Duration fast = DSTokens.animationFast;
  static const Duration normal = DSTokens.animationNormal;
  static const Duration slow = DSTokens.animationSlow;
  static const Duration xSlow = Duration(milliseconds: 800);

  // Micro-interaction animations
  static Widget fadeIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) => Opacity(opacity: value, child: child),
      child: child,
    );
  }

  static Widget slideIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = easeOut,
    Offset begin = const Offset(0, 0.5),
    Offset end = Offset.zero,
  }) {
    return TweenAnimationBuilder<Offset>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) =>
          Transform.translate(offset: value, child: child),
      child: child,
    );
  }

  static Widget scaleIn({
    required Widget child,
    Duration duration = normal,
    Curve curve = spring,
    double begin = 0.8,
    double end = 1.0,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: child,
    );
  }

  // Staggered animations for lists
  static Widget staggeredList({
    required List<Widget> children,
    Duration staggerDelay = const Duration(milliseconds: 100),
    Duration itemDuration = normal,
  }) {
    return Column(
      children: children.asMap().entries.map((entry) {
        final child = entry.value;

        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: itemDuration,
          curve: easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: child,
        );
      }).toList(),
    );
  }
}

/// Animated button dengan hover dan press states
class DSAnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration duration;
  final double scaleOnPress;

  const DSAnimatedButton({
    required this.child,
    this.onPressed,
    this.duration = DSAnimations.fast,
    this.scaleOnPress = 0.95,
    super.key,
  });

  @override
  State<DSAnimatedButton> createState() => _DSAnimatedButtonState();
}

class _DSAnimatedButtonState extends State<DSAnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 1.0, end: widget.scaleOnPress)
        .animate(
          CurvedAnimation(parent: _controller, curve: DSAnimations.easeInOut),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnimation.value, child: widget.child),
      ),
    );
  }
}

/// Loading states dengan skeleton dan shimmer
class DSShimmer extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final Color? baseColor;
  final Color? highlightColor;

  const DSShimmer({
    required this.child,
    required this.isLoading,
    this.baseColor,
    this.highlightColor,
    super.key,
  });

  @override
  State<DSShimmer> createState() => _DSShimmerState();
}

class _DSShimmerState extends State<DSShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoading) return widget.child;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor ?? Colors.grey[300]!,
                widget.highlightColor ?? Colors.grey[100]!,
                widget.baseColor ?? Colors.grey[300]!,
              ],
              stops: [0.0, _controller.value, 1.0],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
    );
  }
}
