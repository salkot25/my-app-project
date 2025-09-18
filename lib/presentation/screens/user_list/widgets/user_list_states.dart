import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tokens/tokens.dart';
import '../../../../design_system/tokens/typography.dart';
import '../../../../design_system/utils/theme_colors.dart';

class UserListStates {
  static Widget buildLoadingState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                const Color(0xFF3498DB),
              ),
            ),
            const SizedBox(height: DSTokens.spaceL),
            Text(
              'Loading users...',
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildEmptyState(
    WidgetRef ref, {
    bool hasFilters = false,
    VoidCallback? onClearFilters,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ref.colors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                hasFilters
                    ? Icons.search_off_rounded
                    : Icons.people_outline_rounded,
                size: 40,
                color: ref.colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSTokens.spaceL),

            // Title
            Text(
              hasFilters ? 'No matching users' : 'No users found',
              style: DSTypography.headlineMedium.copyWith(
                color: ref.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSTokens.spaceM),

            // Description
            Text(
              hasFilters
                  ? 'Try adjusting your search or filters to find what you\'re looking for.'
                  : 'There are no users registered in the system yet.',
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            // Clear filters button
            if (hasFilters && onClearFilters != null) ...[
              const SizedBox(height: DSTokens.spaceL),
              _buildActionButton(
                ref,
                'Clear Filters',
                Icons.filter_list_off_rounded,
                onClearFilters,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildErrorState(
    WidgetRef ref,
    String error, {
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: const Color(0xFFEF4444),
              ),
            ),
            const SizedBox(height: DSTokens.spaceL),

            // Error title
            Text(
              'Something went wrong',
              style: DSTypography.headlineMedium.copyWith(
                color: ref.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSTokens.spaceM),

            // Error message
            Text(
              error,
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            // Retry button
            if (onRetry != null) ...[
              const SizedBox(height: DSTokens.spaceL),
              _buildActionButton(
                ref,
                'Try Again',
                Icons.refresh_rounded,
                onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }

  static Widget buildPermissionDeniedState(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(DSTokens.spaceXL),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Permission icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(height: DSTokens.spaceL),

            // Title
            Text(
              'Access Denied',
              style: DSTypography.headlineMedium.copyWith(
                color: ref.colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSTokens.spaceM),

            // Description
            Text(
              'You don\'t have permission to view user management. Contact your administrator for access.',
              style: DSTypography.bodyMedium.copyWith(
                color: ref.colors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildActionButton(
    WidgetRef ref,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: DSTokens.spaceL,
          vertical: DSTokens.spaceM,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3498DB).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
          border: Border.all(
            color: const Color(0xFF3498DB).withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF3498DB)),
            const SizedBox(width: DSTokens.spaceM),
            Text(
              label,
              style: DSTypography.bodyMedium.copyWith(
                color: const Color(0xFF3498DB),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
