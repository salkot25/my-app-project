import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class SuccessDisplay extends ConsumerWidget {
  final bool isVisible;
  final String title;
  final String message;

  const SuccessDisplay({
    super.key,
    required this.isVisible,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(DSTokens.spaceL),
      margin: const EdgeInsets.only(bottom: DSTokens.spaceL),
      decoration: BoxDecoration(
        color: DSColors.warning.withValues(alpha: 0.1),
        border: Border.all(color: DSColors.warning.withValues(alpha: 0.3), width: 1),
        borderRadius: BorderRadius.circular(DSTokens.radiusM),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(DSTokens.spaceS),
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(DSTokens.radiusS),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: DSColors.warning,
                  size: DSTokens.fontL + DSTokens.spaceXS, // 22px
                ),
              ),
              const SizedBox(width: DSTokens.spaceS + DSTokens.spaceXS), // 12px
              Expanded(
                child: Text(
                  title,
                  style: DSTypography.bodyLarge.copyWith(
                    color: DSColors.warning,
                    fontWeight: DSTokens.fontWeightSemiBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: DSTokens.spaceS + DSTokens.spaceXS), // 12px
          Text(
            message,
            style: DSTypography.bodySmall.copyWith(
              color: DSColors.warning,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
