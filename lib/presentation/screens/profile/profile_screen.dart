import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/design_system.dart';
import '../../providers/auth_provider.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_actions.dart';
import 'widgets/profile_detail_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final currentUser = authState.domainUser;

    void showProfileDetailDialog() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (context) => DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.7,
          maxChildSize: 0.95,
          builder: (context, scrollController) =>
              ProfileDetailDialog(currentUser: currentUser!),
        ),
      );
    }

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: ref.colors.background,
        body: Center(
          child: DSAnimations.fadeIn(
            duration: DSAnimations.slow,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DSAnimations.scaleIn(
                  duration: const Duration(milliseconds: 600),
                  curve: DSAnimations.bounce,
                  child: Icon(
                    Icons.person_off_rounded,
                    size: DSTokens.spaceXXL + DSTokens.spaceL, // 72px
                    color: ref.colors.textTertiary,
                  ),
                ),
                const SizedBox(height: DSTokens.spaceL),
                Text(
                  'No user data available',
                  style: DSTypography.headlineSmall.copyWith(
                    color: ref.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: DSTokens.spaceS),
                Text(
                  'Please login to view your profile',
                  style: DSTypography.bodyMedium.copyWith(
                    color: ref.colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ref.colors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(DSTokens.spaceL),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with modern spacing - Animated fade in
                DSAnimations.fadeIn(
                  child: Text(
                    'Profile',
                    style: DSTypography.displaySmall.copyWith(
                      color: ref.colors.textPrimary,
                      fontWeight: DSTokens.fontWeightBold,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                const SizedBox(height: DSTokens.spaceXS),

                // Description with fade in animation
                DSAnimations.fadeIn(
                  duration: const Duration(milliseconds: 400),
                  child: Text(
                    'Manage your account settings and preferences',
                    style: DSTypography.bodyLarge.copyWith(
                      color: ref.colors.textSecondary,
                      letterSpacing: 0.1,
                    ),
                  ),
                ),

                const SizedBox(height: DSTokens.spaceXL),

                // Profile Header - Slide in from bottom
                DSAnimations.slideIn(
                  begin: const Offset(0, 0.3), // Start from slightly below
                  duration: const Duration(milliseconds: 500),
                  curve: DSAnimations.easeOut,
                  child: ProfileHeader(
                    currentUser: currentUser,
                    onTap: showProfileDetailDialog,
                  ),
                ),

                const SizedBox(height: DSTokens.spaceL),

                // Profile Actions - Scale in animation
                DSAnimations.scaleIn(
                  duration: const Duration(milliseconds: 600),
                  curve: DSAnimations.spring,
                  begin: 0.9,
                  child: ProfileActions(currentUser: currentUser),
                ),

                const SizedBox(height: DSTokens.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
