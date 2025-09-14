import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/design_system.dart';

class RegisterIcon extends ConsumerWidget {
  const RegisterIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: DSTokens.spaceXXXL + DSTokens.spaceXL, // 96px
      height: DSTokens.spaceXXXL + DSTokens.spaceXL, // 96px
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.success.withOpacity(0.2),
            DSColors.success.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        // Enhanced shadow for depth
        boxShadow: [
          BoxShadow(
            color: DSColors.success.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main register icon
          Container(
            width: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
            height: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
            decoration: BoxDecoration(
              color: DSColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(DSTokens.radiusL),
            ),
            child: Icon(
              Icons.person_add_rounded,
              size: DSTokens.spaceXXL, // 48px
              color: DSColors.success,
            ),
          ),
          // Subtle accent dot
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: DSColors.success,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DSColors.success.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
