import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_users_usecase.dart';
import '../../domain/usecases/verify_user_usecase.dart';
import '../../domain/usecases/delete_user_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/update_user_role_usecase.dart';
import '../../domain/usecases/create_user_usecase.dart';
import 'auth_provider.dart';

// User List State
class UserListState {
  final List<User> users;
  final bool isLoading;
  final String? error;

  const UserListState({
    this.users = const [],
    this.isLoading = false,
    this.error,
  });

  UserListState copyWith({List<User>? users, bool? isLoading, String? error}) {
    return UserListState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// User List Notifier using Riverpod 3.0 syntax
class UserListNotifier extends Notifier<UserListState> {
  @override
  UserListState build() {
    return const UserListState();
  }

  Future<void> loadUsers() async {
    final currentUser = ref.read(currentUserProvider);

    // Check if user is authenticated and has permission
    if (currentUser == null) {
      state = state.copyWith(isLoading: false, error: 'Not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    // Get use case from provider
    final getUsersUseCase = GetUsersUseCase(
      userRepository: ref.read(userRepositoryProvider),
    );

    final result = await getUsersUseCase(currentUserUid: currentUser.uid);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (users) =>
          state = state.copyWith(users: users, isLoading: false, error: null),
    );
  }

  Future<void> updateUserStatus(String targetUid, String newStatus) async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      state = state.copyWith(error: 'Not authenticated');
      return;
    }

    // Find user in current list
    final userIndex = state.users.indexWhere((user) => user.uid == targetUid);
    if (userIndex == -1) {
      state = state.copyWith(error: 'User not found');
      return;
    }

    // Optimistic update
    final updatedUsers = List<User>.from(state.users);

    state = state.copyWith(users: updatedUsers);

    // Call use case
    final verifyUserUseCase = VerifyUserUseCase(
      userRepository: ref.read(userRepositoryProvider),
    );

    final result = await verifyUserUseCase(
      currentUserUid: currentUser.uid,
      targetUid: targetUid,
      newStatus: UserStatus.fromString(newStatus),
    );

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(error: failure.message);
      },
      (_) {
        // Update successful - keep the optimistic update
        final finalUsers = List<User>.from(state.users);
        final finalUserIndex = finalUsers.indexWhere((u) => u.uid == targetUid);
        if (finalUserIndex != -1) {
          finalUsers[finalUserIndex] = finalUsers[finalUserIndex].copyWith(
            status: UserStatus.fromString(newStatus),
          );
          state = state.copyWith(users: finalUsers, error: null);
        }
      },
    );
  }

  Future<void> verifyUser({
    required String targetUid,
    required String newStatus,
  }) async {
    await updateUserStatus(targetUid, newStatus);
  }

  Future<void> deleteUser(String targetUid) async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      state = state.copyWith(error: 'Not authenticated');
      return;
    }

    // Check if current user is admin
    if (!currentUser.isAdmin) {
      state = state.copyWith(error: 'Insufficient permissions');
      return;
    }

    // Remove user from list optimistically
    final updatedUsers = state.users.where((u) => u.uid != targetUid).toList();
    state = state.copyWith(users: updatedUsers);

    // Call delete user use case
    final deleteUserUseCase = DeleteUserUseCase(
      userRepository: ref.read(userRepositoryProvider),
    );

    final result = await deleteUserUseCase(
      currentUserUid: currentUser.uid,
      targetUid: targetUid,
    );

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(error: failure.message);
        loadUsers(); // Reload to get correct state
      },
      (_) {
        // Deletion successful - keep the optimistic update
        state = state.copyWith(error: null);
      },
    );
  }

  Future<void> updateUserProfile({
    required String targetUid,
    required String newName,
  }) async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      state = state.copyWith(error: 'Not authenticated');
      return;
    }

    // Check permissions: admin can edit anyone, users can only edit themselves
    if (!currentUser.isAdmin && currentUser.uid != targetUid) {
      state = state.copyWith(error: 'Insufficient permissions');
      return;
    }

    // Find user in current list
    final userIndex = state.users.indexWhere((user) => user.uid == targetUid);
    if (userIndex == -1) {
      state = state.copyWith(error: 'User not found');
      return;
    }

    // Optimistic update
    final updatedUsers = List<User>.from(state.users);
    updatedUsers[userIndex] = updatedUsers[userIndex].copyWith(name: newName);
    state = state.copyWith(users: updatedUsers);

    // Call update user profile use case
    final updateUserProfileUseCase = UpdateUserProfileUseCase(
      userRepository: ref.read(userRepositoryProvider),
    );

    final result = await updateUserProfileUseCase(
      targetUid: targetUid,
      currentUserUid: currentUser.uid,
      newName: newName,
    );

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(error: failure.message);
        loadUsers(); // Reload to get correct state
      },
      (updatedUser) {
        // Update successful - update with server response
        final finalUsers = List<User>.from(state.users);
        final finalUserIndex = finalUsers.indexWhere((u) => u.uid == targetUid);
        if (finalUserIndex != -1) {
          finalUsers[finalUserIndex] = updatedUser;
          state = state.copyWith(users: finalUsers, error: null);
        }
      },
    );
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    required UserStatus status,
  }) async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      state = state.copyWith(error: 'Not authenticated');
      return;
    }

    // Check if current user is admin
    if (!currentUser.isAdmin) {
      state = state.copyWith(error: 'Only admins can create users');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    // Call create user use case
    final createUserUseCase = CreateUserUseCase(
      authRepository: ref.read(authRepositoryProvider),
      userRepository: ref.read(userRepositoryProvider),
    );

    final result = await createUserUseCase(
      email: email,
      password: password,
      name: name,
      currentUserUid: currentUser.uid,
      role: role,
      status: status,
    );

    result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (newUser) {
        final updatedUsers = [...state.users, newUser];
        state = state.copyWith(
          users: updatedUsers,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> updateUserRole(String targetUid, String newRole) async {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      state = state.copyWith(error: 'Not authenticated');
      return;
    }

    // Check if current user is admin
    if (!currentUser.isAdmin) {
      state = state.copyWith(error: 'Insufficient permissions');
      return;
    }

    // Find user in current list
    final userIndex = state.users.indexWhere((user) => user.uid == targetUid);
    if (userIndex == -1) {
      state = state.copyWith(error: 'User not found');
      return;
    }

    // Optimistic update
    final updatedUsers = List<User>.from(state.users);
    updatedUsers[userIndex] = updatedUsers[userIndex].copyWith(
      role: UserRole.fromString(newRole),
    );
    state = state.copyWith(users: updatedUsers);

    // Call update user role use case
    final updateUserRoleUseCase = UpdateUserRoleUseCase(
      userRepository: ref.read(userRepositoryProvider),
    );

    final result = await updateUserRoleUseCase(
      targetUid: targetUid,
      currentUserUid: currentUser.uid,
      newRole: UserRole.fromString(newRole),
    );

    result.fold(
      (failure) {
        // Revert optimistic update on failure
        state = state.copyWith(error: failure.message);
        loadUsers(); // Reload to get correct state
      },
      (updatedUser) {
        // Update successful - update with server response
        final finalUsers = List<User>.from(state.users);
        final finalUserIndex = finalUsers.indexWhere((u) => u.uid == targetUid);
        if (finalUserIndex != -1) {
          finalUsers[finalUserIndex] = updatedUser;
          state = state.copyWith(users: finalUsers, error: null);
        }
      },
    );
  }
}

// Provider using Riverpod 3.0 syntax
final userListProvider = NotifierProvider<UserListNotifier, UserListState>(() {
  return UserListNotifier();
});
