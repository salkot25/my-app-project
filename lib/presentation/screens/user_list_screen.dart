import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../providers/auth_provider.dart';
import '../providers/user_list_provider.dart';

class UserListScreen extends ConsumerStatefulWidget {
  const UserListScreen({super.key});

  @override
  ConsumerState<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends ConsumerState<UserListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  UserRole? _roleFilter;
  UserStatus? _statusFilter;
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
          _statusFilter == null || user.status == _statusFilter;

      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _roleFilter = null;
      _statusFilter = null;
    });
  }

  Future<void> _showVerifyDialog(User user) async {
    final result = await showDialog<UserStatus?>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.verified_user, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text('Update ${user.name}\'s Status'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current status: ${user.status.value.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select new status:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Verified: Full app access\n• Unverified: Limited access\n• Suspended: Account disabled',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (user.status != UserStatus.verified)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(UserStatus.verified),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Verify'),
            ),
          if (user.status != UserStatus.unverified)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(UserStatus.unverified),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.pending, size: 18),
              label: const Text('Unverify'),
            ),
          if (user.status != UserStatus.suspended)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(UserStatus.suspended),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.block, size: 18),
              label: const Text('Suspend'),
            ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _isPerformingAction = true);

      await ref
          .read(userListProvider.notifier)
          .verifyUser(targetUid: user.uid, newStatus: result.value);

      setState(() => _isPerformingAction = false);

      // Show success message
      final actionName = result == UserStatus.verified
          ? 'verified'
          : result == UserStatus.suspended
          ? 'suspended'
          : 'unverified';
      _showSuccessMessage('${user.name} has been $actionName successfully');
    }
  }

  Future<void> _showRoleDialog(User user) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || !currentUser.canChangeRoles) {
      _showErrorMessage('Insufficient permissions to change roles');
      return;
    }

    final result = await showDialog<UserRole?>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.admin_panel_settings, color: Colors.purple.shade700),
            const SizedBox(width: 8),
            Text('Update ${user.name}\'s Role'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.purple.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Current role: ${user.role.value.toUpperCase()}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select new role:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Admin: Full system access\n• Moderator: Can verify users\n• User: Basic access only',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          if (user.role != UserRole.user)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(UserRole.user),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade600,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person, size: 18),
              label: const Text('User'),
            ),
          if (user.role != UserRole.moderator)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(UserRole.moderator),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.shield, size: 18),
              label: const Text('Moderator'),
            ),
          if (user.role != UserRole.admin)
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(UserRole.admin),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.admin_panel_settings, size: 18),
              label: const Text('Admin'),
            ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() => _isPerformingAction = true);

      await ref
          .read(userListProvider.notifier)
          .updateUserRole(user.uid, result.value);

      setState(() => _isPerformingAction = false);

      _showSuccessMessage(
        '${user.name}\'s role has been changed to ${result.value.toUpperCase()}',
      );
    }
  }

  Future<void> _showCreateUserDialog() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || currentUser.role != UserRole.admin) {
      _showErrorMessage('Only admins can create new users');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final nameController = TextEditingController();
    final passwordController = TextEditingController();
    UserRole selectedRole = UserRole.user;
    UserStatus selectedStatus = UserStatus.unverified;
    bool isPasswordVisible = false;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.person_add, color: Colors.green.shade700),
              const SizedBox(width: 8),
              const Text('Add New User'),
            ],
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'New user will receive login credentials via email',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Name field
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Name is required';
                      }
                      if (value.trim().length < 2) {
                        return 'Name must be at least 2 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Email field
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Password field
                  TextFormField(
                    controller: passwordController,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () => setState(
                          () => isPasswordVisible = !isPasswordVisible,
                        ),
                        icon: Icon(
                          isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      helperText: 'Minimum 6 characters',
                    ),
                    obscureText: !isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Role selector
                  DropdownButtonFormField<UserRole>(
                    initialValue: selectedRole,
                    decoration: InputDecoration(
                      labelText: 'User Role',
                      prefixIcon: const Icon(
                        Icons.admin_panel_settings_outlined,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: UserRole.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Row(
                          children: [
                            Icon(
                              role == UserRole.admin
                                  ? Icons.admin_panel_settings
                                  : role == UserRole.moderator
                                  ? Icons.shield
                                  : Icons.person,
                              size: 18,
                              color: _getRoleColor(role),
                            ),
                            const SizedBox(width: 8),
                            Text(role.value.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedRole = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Status selector
                  DropdownButtonFormField<UserStatus>(
                    initialValue: selectedStatus,
                    decoration: InputDecoration(
                      labelText: 'Account Status',
                      prefixIcon: const Icon(Icons.verified_user_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                    ),
                    items: UserStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Row(
                          children: [
                            Icon(
                              status == UserStatus.verified
                                  ? Icons.check_circle
                                  : status == UserStatus.suspended
                                  ? Icons.block
                                  : Icons.pending,
                              size: 18,
                              color: _getStatusColor(status),
                            ),
                            const SizedBox(width: 8),
                            Text(status.value.toUpperCase()),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => selectedStatus = value);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.of(context).pop(true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.person_add, size: 18),
              label: const Text('Create User'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      setState(() => _isPerformingAction = true);

      await ref
          .read(userListProvider.notifier)
          .createUser(
            email: emailController.text.trim(),
            password: passwordController.text,
            name: nameController.text.trim(),
            role: selectedRole,
            status: selectedStatus,
          );

      setState(() => _isPerformingAction = false);

      // Check if creation was successful by monitoring error state
      final error = ref.read(userListProvider).error;
      if (error == null) {
        _showSuccessMessage(
          'User ${nameController.text.trim()} created successfully',
        );
      } else {
        _showErrorMessage(error);
      }
    }

    // Clean up controllers
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
  }

  Future<void> _showEditUserDialog(User user) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null ||
        (!currentUser.canChangeRoles && currentUser.uid != user.uid)) {
      _showErrorMessage('Insufficient permissions to edit this user');
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            Text('Edit ${user.name}'),
          ],
        ),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Current user info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: _getRoleColor(user.role),
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              user.role.value.toUpperCase(),
                              style: TextStyle(
                                color: _getRoleColor(user.role),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        user.isVerified ? Icons.verified : Icons.pending,
                        color: _getStatusColor(
                          user.isVerified
                              ? UserStatus.verified
                              : UserStatus.unverified,
                        ),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Name field
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Name must be at least 2 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field (read-only)
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: const Icon(Icons.email_outlined),
                    suffixIcon: const Icon(Icons.lock_outline, size: 18),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                  ),
                  keyboardType: TextInputType.emailAddress,
                  enabled: false, // Email can't be changed in Firebase Auth
                ),

                // Info note
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Colors.orange.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Email address cannot be modified due to Firebase authentication constraints',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.save, size: 18),
            label: const Text('Update Profile'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final hasChanges = nameController.text.trim() != user.name;

      if (!hasChanges) {
        _showErrorMessage('No changes detected');
        return;
      }

      setState(() => _isPerformingAction = true);

      await ref
          .read(userListProvider.notifier)
          .updateUserProfile(
            targetUid: user.uid,
            newName: nameController.text.trim(),
          );

      setState(() => _isPerformingAction = false);

      // Check if update was successful
      final error = ref.read(userListProvider).error;
      if (error == null) {
        _showSuccessMessage(
          '${nameController.text.trim()} profile updated successfully',
        );
      } else {
        _showErrorMessage(error);
      }
    }

    // Clean up controllers
    nameController.dispose();
    emailController.dispose();
  }

  Future<void> _showUserDetailDialog(User user) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person, color: Colors.blue.shade700),
            const SizedBox(width: 8),
            const Text('User Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Profile Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getRoleColor(user.role).withValues(alpha: 0.1),
                      _getRoleColor(user.role).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getRoleColor(user.role).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: _getRoleColor(user.role),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(user.role),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.value.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              user.isVerified
                                  ? UserStatus.verified
                                  : UserStatus.unverified,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.isVerified ? 'VERIFIED' : 'UNVERIFIED',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Account Information Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Account Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildDetailRow('User ID', user.uid),
                    const SizedBox(height: 8),
                    _buildDetailRow('Email', user.email),
                    const SizedBox(height: 8),
                    _buildDetailRow('Role', user.role.value.toUpperCase()),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Status',
                      user.isVerified ? 'VERIFIED' : 'UNVERIFIED',
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Created At',
                      user.createdAt.toString().split('.')[0],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Updated At',
                      user.updatedAt.toString().split('.')[0],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Permissions Section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.security,
                          color: Colors.green.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Permissions & Capabilities',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    _buildPermissionChip(
                      'Can verify users',
                      user.canVerifyUsers,
                    ),
                    _buildPermissionChip(
                      'Can change roles',
                      user.canChangeRoles,
                    ),
                    _buildPermissionChip(
                      'Can delete users',
                      user.canDeleteUsers,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: SelectableText(value)),
      ],
    );
  }

  Widget _buildPermissionChip(String label, bool hasPermission) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: hasPermission ? Colors.green.shade100 : Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: hasPermission ? Colors.green.shade300 : Colors.red.shade300,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: hasPermission ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                hasPermission ? Icons.check : Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: hasPermission
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
            Text(
              hasPermission ? 'GRANTED' : 'DENIED',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: hasPermission
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(User user) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || !currentUser.canDeleteUsers) {
      _showErrorMessage('Insufficient permissions to delete users');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red.shade700),
            const SizedBox(width: 8),
            const Text('Delete User'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User info to be deleted
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getRoleColor(user.role),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.admin_panel_settings,
                                size: 16,
                                color: _getRoleColor(user.role),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                user.role.value.toUpperCase(),
                                style: TextStyle(
                                  color: _getRoleColor(user.role),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Warning message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'This action is permanent!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '• User account will be completely removed\n'
                      '• All associated data will be deleted\n'
                      '• This action cannot be undone',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Confirmation text
              Text(
                'Are you absolutely sure you want to delete this user?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.delete_forever, size: 18),
            label: const Text('Delete User'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isPerformingAction = true);

      await ref.read(userListProvider.notifier).deleteUser(user.uid);

      setState(() => _isPerformingAction = false);

      // Check if deletion was successful
      final error = ref.read(userListProvider).error;
      if (error == null) {
        _showSuccessMessage('User ${user.name} deleted successfully');
      } else {
        _showErrorMessage(error);
      }
    }
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF3498DB) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF3498DB) : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF2C3E50),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(UserStatus status) {
    switch (status) {
      case UserStatus.verified:
        return const Color(0xFF10B981); // Modern green
      case UserStatus.unverified:
        return const Color(0xFFF59E0B); // Modern amber
      case UserStatus.suspended:
        return const Color(0xFFEF4444); // Modern red
    }
  }

  Color _getRoleColor(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return const Color(0xFF8B5CF6); // Modern purple
      case UserRole.moderator:
        return const Color(0xFF3B82F6); // Modern blue
      case UserRole.user:
        return const Color(0xFF6B7280); // Modern gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final userListState = ref.watch(userListProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2C3E50),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        title: const Text(
          'Users',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
        actions: [
          // Add User button for admins
          if (currentUser?.canChangeRoles == true)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: IconButton.filledTonal(
                onPressed: userListState.isLoading
                    ? null
                    : _showCreateUserDialog,
                icon: const Icon(Icons.add, size: 20),
                tooltip: 'Add New User',
                style: IconButton.styleFrom(
                  backgroundColor: const Color(
                    0xFF3498DB,
                  ).withValues(alpha: 0.1),
                  foregroundColor: const Color(0xFF3498DB),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton.outlined(
              onPressed: userListState.isLoading
                  ? null
                  : () => ref.read(userListProvider.notifier).loadUsers(),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              tooltip: 'Refresh',
              style: IconButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade300),
                foregroundColor: const Color(0xFF2C3E50),
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  ref.read(authProvider.notifier).logout();
                } else if (value == 'profile') {
                  context.go('/profile');
                }
              },
              icon: const Icon(Icons.more_vert_rounded, size: 20),
              surfaceTintColor: Colors.transparent,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 12),
                      const Text('Profile', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(
                        Icons.logout_rounded,
                        size: 18,
                        color: Colors.grey.shade700,
                      ),
                      const SizedBox(width: 12),
                      const Text('Logout', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Modern Search Section
          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search users...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                              icon: Icon(
                                Icons.close_rounded,
                                color: Colors.grey.shade400,
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                    enabled: !_isPerformingAction && !userListState.isLoading,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Minimal Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Role filters
                      _buildFilterChip(
                        'All Roles',
                        _roleFilter == null,
                        () => setState(() => _roleFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Admin',
                        _roleFilter == UserRole.admin,
                        () => setState(() => _roleFilter = UserRole.admin),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Moderator',
                        _roleFilter == UserRole.moderator,
                        () => setState(() => _roleFilter = UserRole.moderator),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'User',
                        _roleFilter == UserRole.user,
                        () => setState(() => _roleFilter = UserRole.user),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        height: 20,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(width: 16),
                      // Status filters
                      _buildFilterChip(
                        'All Status',
                        _statusFilter == null,
                        () => setState(() => _statusFilter = null),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Verified',
                        _statusFilter == UserStatus.verified,
                        () =>
                            setState(() => _statusFilter = UserStatus.verified),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Unverified',
                        _statusFilter == UserStatus.unverified,
                        () => setState(
                          () => _statusFilter = UserStatus.unverified,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        'Suspended',
                        _statusFilter == UserStatus.suspended,
                        () => setState(
                          () => _statusFilter = UserStatus.suspended,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Modern User Info Strip
          if (currentUser != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFF8F9FA),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3498DB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: const Color(0xFF3498DB),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${currentUser.name} • ${currentUser.role.value.toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2C3E50),
                      ),
                    ),
                  ),
                  if (!userListState.isLoading) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Text(
                        '${_getFilteredUsers(userListState.users).length}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          // Modern Error Display
          if (userListState.error != null)
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade600,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userListState.error!,
                      style: TextStyle(
                        color: Colors.red.shade800,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () =>
                        ref.read(userListProvider.notifier).clearError(),
                    icon: Icon(
                      Icons.close_rounded,
                      color: Colors.red.shade600,
                      size: 18,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          Expanded(
            child: userListState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Builder(
                    builder: (context) {
                      final filteredUsers = _getFilteredUsers(
                        userListState.users,
                      );
                      if (filteredUsers.isEmpty) {
                        return Center(
                          child: Container(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    userListState.users.isEmpty
                                        ? Icons.people_outline_rounded
                                        : Icons.search_off_rounded,
                                    size: 40,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  userListState.users.isEmpty
                                      ? 'No users yet'
                                      : 'No matching users',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2C3E50),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  userListState.users.isEmpty
                                      ? 'Users will appear here once they\'re added'
                                      : 'Try adjusting your search or filters',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (userListState.users.isNotEmpty) ...[
                                  const SizedBox(height: 16),
                                  TextButton.icon(
                                    onPressed: _clearFilters,
                                    icon: const Icon(
                                      Icons.clear_all_rounded,
                                      size: 18,
                                    ),
                                    label: const Text('Clear filters'),
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF3498DB),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filteredUsers.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade200),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade100,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Modern Avatar
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: _getRoleColor(
                                      user.role,
                                    ).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: _getRoleColor(
                                        user.role,
                                      ).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      user.name.isNotEmpty
                                          ? user.name[0].toUpperCase()
                                          : 'U',
                                      style: TextStyle(
                                        color: _getRoleColor(user.role),
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // User Info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2C3E50),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        user.email,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      // Modern Status Chips
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getRoleColor(user.role),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              user.role.value.toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _getStatusColor(
                                                user.status,
                                              ).withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  width: 6,
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: _getStatusColor(
                                                      user.status,
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          3,
                                                        ),
                                                  ),
                                                ),
                                                const SizedBox(width: 6),
                                                Text(
                                                  user.status.value
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: _getStatusColor(
                                                      user.status,
                                                    ),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Modern Actions Menu
                                PopupMenuButton<String>(
                                  icon: Icon(
                                    Icons.more_vert_rounded,
                                    color: Colors.grey.shade400,
                                    size: 20,
                                  ),
                                  surfaceTintColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'details':
                                        _showUserDetailDialog(user);
                                        break;
                                      case 'edit':
                                        _showEditUserDialog(user);
                                        break;
                                      case 'verify':
                                        _showVerifyDialog(user);
                                        break;
                                      case 'role':
                                        _showRoleDialog(user);
                                        break;
                                      case 'delete':
                                        _confirmDelete(user);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                      value: 'details',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline_rounded,
                                            size: 18,
                                            color: Colors.grey.shade700,
                                          ),
                                          const SizedBox(width: 12),
                                          const Text(
                                            'View Details',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (currentUser?.canChangeRoles == true ||
                                        currentUser?.uid == user.uid)
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.edit_outlined,
                                              size: 18,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Edit Profile',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (currentUser?.canVerifyUsers == true)
                                      PopupMenuItem(
                                        value: 'verify',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.verified_user_outlined,
                                              size: 18,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Update Status',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (currentUser?.canChangeRoles == true)
                                      PopupMenuItem(
                                        value: 'role',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons
                                                  .admin_panel_settings_outlined,
                                              size: 18,
                                              color: Colors.grey.shade700,
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Change Role',
                                              style: TextStyle(fontSize: 14),
                                            ),
                                          ],
                                        ),
                                      ),
                                    if (currentUser?.canDeleteUsers == true &&
                                        user.uid != currentUser?.uid)
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.delete_outline_rounded,
                                              size: 18,
                                              color: Colors.red.shade600,
                                            ),
                                            const SizedBox(width: 12),
                                            Text(
                                              'Delete User',
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
