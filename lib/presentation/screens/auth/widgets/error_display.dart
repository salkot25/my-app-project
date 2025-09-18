import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class ErrorDisplay extends ConsumerStatefulWidget {
  final String? errorMessage;
  final AnimationController shakeController;

  const ErrorDisplay({
    super.key,
    required this.errorMessage,
    required this.shakeController,
  });

  @override
  ConsumerState<ErrorDisplay> createState() => _ErrorDisplayState();
}

class _ErrorDisplayState extends ConsumerState<ErrorDisplay> {
  @override
  Widget build(BuildContext context) {
    if (widget.errorMessage == null || widget.errorMessage!.isEmpty) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: widget.shakeController,
      builder: (context, child) {
        // Shake animation - horizontal offset based on sine wave
        final offset =
            widget.shakeController.value *
            10 *
            (widget.shakeController.value < 0.5 ? 1 : -1);

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(DSTokens.spaceM),
            margin: const EdgeInsets.only(bottom: DSTokens.spaceL),
            decoration: BoxDecoration(
              color: DSColors.error.withValues(alpha: 0.1),
              border: Border.all(
                color: DSColors.error.withValues(alpha: 0.3),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(DSTokens.radiusM),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: DSColors.error, size: 20),
                const SizedBox(width: DSTokens.spaceS),
                Expanded(
                  child: Text(
                    widget.errorMessage!,
                    style: DSTypography.bodySmall.copyWith(
                      color: DSColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
