import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_gate.dart';
import '../widgets/status_gate.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'user_list_screen.dart';

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
          index: 1,
          icon: Icons.people_outline_rounded,
          activeIcon: Icons.people_rounded,
          label: 'Users',
          isSelected: _selectedIndex == 1,
          roleColor: _getRoleColor(currentUser.role),
        ),
      _buildNavItem(
        context: context,
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
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? roleColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon with smooth transition
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  key: ValueKey(isSelected),
                  color: isSelected ? roleColor : const Color(0xFF6B7280),
                  size: 22,
                ),
              ),

              const SizedBox(height: 2),

              // Label with color animation
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? roleColor : const Color(0xFF6B7280),
                  letterSpacing: 0.1,
                ),
                child: Text(label),
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
        return const Color(0xFFDC2626); // Red
      case UserRole.moderator:
        return const Color(0xFF7C3AED); // Purple
      case UserRole.user:
        return const Color(0xFF059669); // Green
    }
  }
}
