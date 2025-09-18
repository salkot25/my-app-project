import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class OnboardingTooltip extends ConsumerWidget {
  final String message;
  final VoidCallback onNext;
  final VoidCallback onSkip;
  final int currentStep;
  final int totalSteps;
  final bool showSkip;

  const OnboardingTooltip({
    super.key,
    required this.message,
    required this.onNext,
    required this.onSkip,
    required this.currentStep,
    required this.totalSteps,
    this.showSkip = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(DSTokens.spaceM),
      padding: const EdgeInsets.all(DSTokens.spaceL),
      decoration: BoxDecoration(
        color: ref.colors.surface,
        borderRadius: BorderRadius.circular(DSTokens.radiusL),
        border: Border.all(
          color: DSColors.brandPrimary.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: DSColors.brandPrimary.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DSTokens.spaceS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: DSColors.brandPrimary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$currentStep of $totalSteps',
                  style: DSTypography.labelSmall.copyWith(
                    color: DSColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              if (showSkip)
                TextButton(
                  onPressed: onSkip,
                  style: TextButton.styleFrom(
                    foregroundColor: ref.colors.textSecondary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: DSTokens.spaceS,
                    ),
                  ),
                  child: Text(
                    'Skip tour',
                    style: DSTypography.labelSmall.copyWith(
                      color: ref.colors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: DSTokens.spaceM),

          // Message
          Text(
            message,
            style: DSTypography.bodyMedium.copyWith(
              color: ref.colors.textPrimary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: DSTokens.spaceL),

          // Next button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: DSColors.brandPrimary,
                foregroundColor: DSColors.textOnColor,
                padding: const EdgeInsets.symmetric(vertical: DSTokens.spaceM),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSTokens.radiusM),
                ),
              ),
              child: Text(
                currentStep == totalSteps ? 'Get Started' : 'Next',
                style: DSTypography.labelMedium.copyWith(
                  color: DSColors.textOnColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
