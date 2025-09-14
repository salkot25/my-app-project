import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/offline_first_user_repository.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/user_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

// Firebase instances
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

// Data sources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(firebaseAuth: ref.watch(firebaseAuthProvider));
});

final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  return UserRemoteDataSource(firestore: ref.watch(firestoreProvider));
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authRemoteDataSource: ref.watch(authRemoteDataSourceProvider),
  );
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  // Use offline-first repository for better offline experience
  return ref.watch(offlineFirstUserRepositoryProvider);
});

// Use cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(
    authRepository: ref.watch(authRepositoryProvider),
    userRepository: ref.watch(userRepositoryProvider),
  );
});

// Authentication state management
class AuthState {
  const AuthState({
    this.firebaseUser,
    this.domainUser,
    this.isLoading = false,
    this.error,
  });

  final User? firebaseUser;
  final domain.User? domainUser;
  final bool isLoading;
  final String? error;

  bool get isAuthenticated => firebaseUser != null && domainUser != null;
  bool get isVerified => domainUser?.isVerified ?? false;

  AuthState copyWith({
    User? firebaseUser,
    domain.User? domainUser,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      firebaseUser: firebaseUser ?? this.firebaseUser,
      domainUser: domainUser ?? this.domainUser,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier using Riverpod 3.0 syntax
class AuthNotifier extends Notifier<AuthState> {
  StreamSubscription<User?>? _authSubscription;

  @override
  AuthState build() {
    final firebaseAuth = ref.read(firebaseAuthProvider);

    // Check if there's already a current user (from persistence)
    final currentUser = firebaseAuth.currentUser;

    print('AuthNotifier build - Current user: ${currentUser?.email ?? 'null'}');

    // Initialize with current user if exists, but still loading profile
    final initialState = currentUser != null
        ? AuthState(firebaseUser: currentUser, isLoading: true)
        : const AuthState(isLoading: true);

    // Listen to Firebase auth state changes
    final authRepository = ref.read(authRepositoryProvider);
    _authSubscription = authRepository.authStateChanges.listen(
      _onAuthStateChanged,
    );

    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    // Load initial profile if user exists
    if (currentUser != null) {
      _loadUserProfile(currentUser);
    } else {
      // No current user, set state to not loading
      Future.microtask(() {
        if (state.isLoading && state.firebaseUser == null) {
          state = const AuthState(isLoading: false);
        }
      });
    }

    return initialState;
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    print('Auth state changed: ${firebaseUser?.email ?? 'null'}');

    if (firebaseUser == null) {
      print('No Firebase user, setting empty state');
      state = const AuthState(isLoading: false);
      return;
    }

    print('Firebase user found, loading profile for UID: ${firebaseUser.uid}');
    state = state.copyWith(
      firebaseUser: firebaseUser,
      isLoading: true,
      error: null,
    );

    await _loadUserProfile(firebaseUser);
  }

  Future<void> _loadUserProfile(User firebaseUser) async {
    final userRepository = ref.read(userRepositoryProvider);

    // Get domain user profile
    print('Fetching user profile from Firestore...');
    final result = await userRepository.getUserProfile(firebaseUser.uid);

    result.fold(
      (failure) {
        print('Failed to get user profile: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (domainUser) {
        print('User profile loaded successfully: ${domainUser.email}');
        state = state.copyWith(
          domainUser: domainUser,
          isLoading: false,
          error: null,
        );
      },
    );
  }

  Future<void> login({required String email, required String password}) async {
    print('Login attempt for: $email');
    state = state.copyWith(isLoading: true, error: null);

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        print('Login failed: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (user) {
        print('Login successful for user: ${user.email}');
        // Auth state will be updated through the auth state listener
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final registerUseCase = ref.read(registerUseCaseProvider);
    final result = await registerUseCase(
      email: email,
      password: password,
      name: name,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (user) => {
        // Auth state will be updated through the auth state listener
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.signOut();

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (_) => {
        // Auth state will be updated through the auth state listener
      },
    );
  }

  Future<void> updateProfile({
    required String name,
    required String email,
  }) async {
    // Check if user is authenticated
    if (state.domainUser == null || state.firebaseUser == null) {
      state = state.copyWith(error: 'User not authenticated');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    final userRepository = ref.read(userRepositoryProvider);
    final currentUser = state.domainUser!;

    final result = await userRepository.updateUserProfile(
      uid: currentUser.uid,
      currentUserUid: currentUser.uid,
      name: name != currentUser.name ? name : null,
      email: email != currentUser.email ? email : null,
    );

    result.fold(
      (failure) {
        print('Failed to update profile: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
      },
      (updatedUser) {
        print('Profile updated successfully: ${updatedUser.email}');
        state = state.copyWith(
          domainUser: updatedUser,
          isLoading: false,
          error: null,
        );
      },
    );
  }
}

// Auth provider using Riverpod 3.0 syntax
final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

// Current user provider
final currentUserProvider = Provider<domain.User?>((ref) {
  return ref.watch(authProvider).domainUser;
});

// Authentication status providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final isVerifiedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isVerified;
});
