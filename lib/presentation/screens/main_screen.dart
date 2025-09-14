import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../design_system/design_system.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_gate.dart';
import '../widgets/status_gate.dart';
import 'home_screen.dart';
import 'profile/profile_screen.dart';
import 'user_list/user_list_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    // Build screens list based on user permissions
    List<Widget> screens = [
      const HomeScreen(),
      if (currentUser.canViewAllUsers)
        const VerifiedGate(child: ModeratorGate(child: UserListScreen())),
      const ProfileScreen(),
    ];

    // Build navigation items based on user permissions
    List<Widget> navItems = [
      _buildNavItem(
        context: context,
        ref: ref,
        index: 0,
        icon: Icons.home_rounded,
        activeIcon: Icons.home_rounded,
        label: 'Home',
        isSelected: _selectedIndex == 0,
        roleColor: _getRoleColor(currentUser.role),
      ),
      if (currentUser.canViewAllUsers)
        _buildNavItem(
          context: context,
          ref: ref,
          index: 1,
          icon: Icons.people_outline_rounded,
          activeIcon: Icons.people_rounded,
          label: 'Users',
          isSelected: _selectedIndex == 1,
          roleColor: _getRoleColor(currentUser.role),
        ),
      _buildNavItem(
        context: context,
        ref: ref,
        index: currentUser.canViewAllUsers ? 2 : 1,
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        isSelected: _selectedIndex == (currentUser.canViewAllUsers ? 2 : 1),
        roleColor: _getRoleColor(currentUser.role),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ref.colors.surface,
          border: Border(
            top: BorderSide(
              color: ref.colors.border.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: ref.colors.shadowColor.withValues(alpha: 0.08),
              blurRadius: DSTokens.spaceM,
              offset: const Offset(0, -2),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: ref.colors.shadowColor.withValues(alpha: 0.04),
              blurRadius: DSTokens.spaceL,
              offset: const Offset(0, -8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 92, // Slightly increased for better proportions
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceL,
              vertical: DSTokens.spaceS,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: navItems,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required WidgetRef ref,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isSelected,
    required Color roleColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedIndex = index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          padding: EdgeInsets.symmetric(
            vertical: isSelected ? DSTokens.spaceS : DSTokens.spaceXS,
            horizontal: DSTokens.spaceS,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? roleColor.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(DSTokens.radiusL),
            border: isSelected
                ? Border.all(color: roleColor.withValues(alpha: 0.2), width: 1)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with enhanced transition and micro-interactions
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 6 : 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? roleColor.withValues(alpha: 0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(
                      scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.elasticOut,
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? roleColor : ref.colors.textSecondary,
                    size: isSelected ? 22 : 20, // Dynamic size
                  ),
                ),
              ),

              const SizedBox(height: 6), // Increased spacing
              // Enhanced label with better typography
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isSelected ? 11 : 10, // Dynamic font size
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? roleColor : ref.colors.textSecondary,
                  letterSpacing: isSelected ? 0.2 : 0.1,
                  height: 1.2,
                ),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: isSelected ? 1.02 : 1.0,
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return DSColors.error; // Consistent with design system
      case UserRole.moderator:
        return DSColors.brandPrimary; // Consistent with design system
      case UserRole.user:
        return DSColors.success; // Consistent with design system
    }
  }
}
