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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_rounded,
                size: DSTokens.spaceXXL + DSTokens.spaceL, // 72px
                color: ref.colors.textTertiary,
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
                // Header Section with modern spacing
                Text(
                  'Profile',
                  style: DSTypography.displaySmall.copyWith(
                    color: ref.colors.textPrimary,
                    fontWeight: DSTokens.fontWeightBold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: DSTokens.spaceXS),
                Text(
                  'Manage your account settings and preferences',
                  style: DSTypography.bodyLarge.copyWith(
                    color: ref.colors.textSecondary,
                    letterSpacing: 0.1,
                  ),
                ),

                const SizedBox(height: DSTokens.spaceXL),

                // Profile Header
                ProfileHeader(
                  currentUser: currentUser,
                  onTap: showProfileDetailDialog,
                ),

                const SizedBox(height: DSTokens.spaceL),

                // Profile Actions
                ProfileActions(currentUser: currentUser),

                const SizedBox(height: DSTokens.spaceXXL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
