import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/design_system.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/entities/user_status.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_list_provider.dart';
import 'widgets/user_search_section.dart';
import 'widgets/user_card.dart';
import 'widgets/user_dialogs.dart';
import 'widgets/user_list_states.dart';
import 'widgets/user_stats_card.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _roleFilter;
  UserStatusFilter? _statusFilter;
  bool _isPerformingAction = false;

  @override
  void initState() {
    super.initState();
    // Load users when the screen is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userListProvider.notifier).loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<User> _getFilteredUsers(List<User> users) {
    return users.where((user) {
      // Search filter
      final matchesSearch =
          _searchQuery.isEmpty ||
          user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());

      // Role filter
      final matchesRole = _roleFilter == null || user.role == _roleFilter;

      // Status filter
      final matchesStatus =
          _statusFilter == null ||
          _statusFilter == UserStatusFilter.all ||
          (_statusFilter == UserStatusFilter.verified &&
              user.status == UserStatus.verified) ||
          (_statusFilter == UserStatusFilter.unverified &&
              user.status == UserStatus.unverified) ||
          (_statusFilter == UserStatusFilter.suspended &&
              user.status == UserStatus.suspended);

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty || _roleFilter != null || _statusFilter != null;

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _roleFilter = null;
      _statusFilter = null;
      _searchController.clear();
    });
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: DSColors.white),
            const SizedBox(width: DSTokens.spaceS),
            Text(
              message,
              style: DSTypography.bodyMedium.copyWith(color: DSColors.white),
            ),
          ],
        ),
        backgroundColor: DSColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: DSColors.white),
            const SizedBox(width: DSTokens.spaceS),
            Expanded(
              child: Text(
                message,
                style: DSTypography.bodyMedium.copyWith(color: DSColors.white),
              ),
            ),
          ],
        ),
        backgroundColor: DSColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DSTokens.radiusM),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleRoleChange(User user, UserRole newRole) async {
    if (_isPerformingAction) return;

    setState(() {
      _isPerformingAction = true;
    });

    try {
      await ref
          .read(userListProvider.notifier)
          .updateUserRole(user.uid, newRole.value);
      _showSuccessMessage('User role updated successfully');
    } catch (e) {
      _showErrorMessage('Error updating user role: ${e.toString()}');
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<void> _handleStatusChange(User user, UserStatus newStatus) async {
    if (_isPerformingAction) return;

    setState(() {
      _isPerformingAction = true;
    });

    try {
      await ref
          .read(userListProvider.notifier)
          .updateUserStatus(user.uid, newStatus.value);
      _showSuccessMessage('User status updated successfully');
    } catch (e) {
      _showErrorMessage('Error updating user status: ${e.toString()}');
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<void> _handleDeleteUser(User user) async {
    if (_isPerformingAction) return;

    final confirmed = await UserDialogs.showDeleteConfirmationDialog(
      context,
      ref,
      user,
    );

    if (!confirmed) return;

    setState(() {
      _isPerformingAction = true;
    });

    try {
      await ref.read(userListProvider.notifier).deleteUser(user.uid);
      _showSuccessMessage('User deleted successfully');
    } catch (e) {
      _showErrorMessage('Error deleting user: ${e.toString()}');
    } finally {
      setState(() {
        _isPerformingAction = false;
      });
    }
  }

  Future<void> _handleRefresh() async {
    try {
      await ref.read(userListProvider.notifier).loadUsers();
    } catch (e) {
      _showErrorMessage('Error refreshing users: ${e.toString()}');
    }
  }

  void _navigateToUserDetail(User user) {
    context.push('/users/${user.uid}');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userListState = ref.watch(userListProvider);

    return Scaffold(
      backgroundColor: ref.colors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header Section - same style as Profile Screen
            Padding(
              padding: const EdgeInsets.fromLTRB(
                DSTokens.spaceL,
                DSTokens.spaceL,
                DSTokens.spaceL,
                0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Users',
                          style: DSTypography.displaySmall.copyWith(
                            color: ref.colors.textPrimary,
                            fontWeight: DSTokens.fontWeightBold,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: DSTokens.spaceXS),
                        Text(
                          'Manage user accounts and permissions',
                          style: DSTypography.bodyLarge.copyWith(
                            color: ref.colors.textSecondary,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Refresh button
                  Container(
                    decoration: BoxDecoration(
                      color: ref.colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(DSTokens.radiusL),
                      border: Border.all(color: ref.colors.border, width: 1),
                    ),
                    child: IconButton(
                      onPressed: _isPerformingAction ? null : _handleRefresh,
                      icon: Icon(
                        Icons.refresh_rounded,
                        color: _isPerformingAction
                            ? ref.colors.textTertiary
                            : ref.colors.textSecondary,
                        size: DSTokens.fontL,
                      ),
                      tooltip: 'Refresh users',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: DSTokens.spaceS),

            // Stats Card - moved to top
            userListState.isLoading
                ? Container()
                : userListState.error != null
                ? Container()
                : UserStatsCard(
                    users: userListState.users,
                    selectedFilter: _statusFilter,
                    onFilterChanged: (filter) {
                      setState(() {
                        _statusFilter = filter == UserStatusFilter.all
                            ? null
                            : filter;
                      });
                    },
                  ),

            //const SizedBox(height: DSTokens.spaceS),

            // Search Section
            UserSearchSection(
              searchController: _searchController,
              searchQuery: _searchQuery,
              roleFilter: _roleFilter,
              isEnabled: !_isPerformingAction,
              onSearchChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onRoleFilterChanged: (role) {
                setState(() {
                  _roleFilter = role;
                });
              },
            ),

            // Content
            Expanded(child: _buildContent(authState, userListState)),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AuthState authState, UserListState userListState) {
    // Handle loading state
    if (userListState.isLoading) {
      return UserListStates.buildLoadingState(ref);
    }

    // Handle error state
    if (userListState.error != null) {
      // Check if it's a permission error
      if (userListState.error!.toLowerCase().contains('permission')) {
        return UserListStates.buildPermissionDeniedState(ref);
      }

      return UserListStates.buildErrorState(
        ref,
        userListState.error!,
        onRetry: () {
          ref.read(userListProvider.notifier).loadUsers();
        },
      );
    }

    // Handle success state with data
    final users = userListState.users;
    final filteredUsers = _getFilteredUsers(users);
    final currentUser = authState.domainUser;

    return RefreshIndicator(
      onRefresh: _handleRefresh,
      color: DSColors.brandPrimary,
      backgroundColor: ref.colors.surface,
      child: filteredUsers.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                child: UserListStates.buildEmptyState(
                  ref,
                  hasFilters: _hasActiveFilters,
                  onClearFilters: _hasActiveFilters ? _clearFilters : null,
                ),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                final isCurrentUser = currentUser?.uid == user.uid;
                final canManageUser =
                    currentUser?.canViewAllUsers == true && !isCurrentUser;

                return UserCard(
                  user: user,
                  isCurrentUser: isCurrentUser,
                  isEnabled: !_isPerformingAction,
                  onEdit: () => _navigateToUserDetail(user),
                  onDelete: canManageUser && currentUser?.canDeleteUsers == true
                      ? () => _handleDeleteUser(user)
                      : null,
                  onRoleChanged:
                      canManageUser && currentUser?.canChangeRoles == true
                      ? (role) => _handleRoleChange(user, role)
                      : null,
                  onStatusChanged:
                      canManageUser && currentUser?.canVerifyUsers == true
                      ? (status) => _handleStatusChange(user, status)
                      : null,
                );
              },
            ),
    );
  }
}
