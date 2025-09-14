import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class WelcomeHeader extends ConsumerWidget {
  final String title;
  final String subtitle;

  const WelcomeHeader({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Welcome Text
        Text(
          title,
          style: DSTypography.displayMedium.copyWith(
            color: ref.colors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: DSTokens.spaceS),
        Text(
          subtitle,
          style: DSTypography.bodyMedium.copyWith(
            color: ref.colors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
