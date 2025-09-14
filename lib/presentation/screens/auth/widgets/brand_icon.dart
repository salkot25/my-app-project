import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';

class BrandIcon extends StatelessWidget {
  const BrandIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DSTokens.spaceXXXL + DSTokens.spaceXL, // 96px
      height: DSTokens.spaceXXXL + DSTokens.spaceXL, // 96px
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.brandPrimary.withValues(alpha: 0.2),
            DSColors.brandPrimary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        // Enhanced shadow for depth
        boxShadow: [
          BoxShadow(
            color: DSColors.brandPrimary.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main app icon - using a more branded approach
          Container(
            width: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
            height: DSTokens.spaceXXL + DSTokens.spaceM, // 64px
            decoration: BoxDecoration(
              color: DSColors.brandPrimary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(DSTokens.radiusL),
            ),
            child: Icon(
              Icons.account_circle_rounded,
              size: DSTokens.spaceXXL, // 48px
              color: DSColors.brandPrimary,
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
                color: DSColors.brandPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: DSColors.brandPrimary.withValues(alpha: 0.3),
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
