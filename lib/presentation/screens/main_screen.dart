import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/design_system.dart';
import '../providers/auth_provider.dart';
import '../../design_system/utils/role_colors.dart';
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
        roleColor: RoleColors.getRoleColor(currentUser.role),
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
          roleColor: RoleColors.getRoleColor(currentUser.role),
        ),
      _buildNavItem(
        context: context,
        ref: ref,
        index: currentUser.canViewAllUsers ? 2 : 1,
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
        label: 'Profile',
        isSelected: _selectedIndex == (currentUser.canViewAllUsers ? 2 : 1),
        roleColor: RoleColors.getRoleColor(currentUser.role),
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: ref.colors.surface,
          border: Border(
            top: BorderSide(
              color: ref.colors.border.withValues(alpha: 0.08),
              width: 0.5,
            ),
          ),
        ),
        child: SafeArea(
          child: Container(
            height: 64, // More compact height
            padding: const EdgeInsets.symmetric(
              horizontal: DSTokens.spaceM,
              vertical: DSTokens.spaceXS,
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
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: DSTokens.spaceS,
            horizontal: DSTokens.spaceXS,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Simplified icon
              Icon(
                isSelected ? activeIcon : icon,
                color: isSelected ? roleColor : ref.colors.textSecondary,
                size: 20,
              ),
              const SizedBox(height: 4),
              // Simplified label
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? roleColor : ref.colors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
