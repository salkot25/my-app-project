import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/local_database_service.dart';
import '../../domain/entities/user.dart' as domain;
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

/// Enhanced authentication state with offline support
class OfflineAuthState {
  final firebase_auth.User? firebaseUser;
  final domain.User? domainUser;
  final bool isLoading;
  final String? error;
  final bool isOfflineMode;

  const OfflineAuthState({
    this.firebaseUser,
    this.domainUser,
    this.isLoading = false,
    this.error,
    this.isOfflineMode = false,
  });

  const OfflineAuthState.loading() : this(isLoading: true);

  const OfflineAuthState.unauthenticated() : this();

  const OfflineAuthState.authenticated({
    required firebase_auth.User firebaseUser,
    required domain.User domainUser,
  }) : this(firebaseUser: firebaseUser, domainUser: domainUser);

  const OfflineAuthState.authenticatedOffline({
    required String email,
    required domain.User domainUser,
  }) : this(domainUser: domainUser, isOfflineMode: true);

  const OfflineAuthState.authenticatedWithError({
    required firebase_auth.User firebaseUser,
    required String error,
  }) : this(firebaseUser: firebaseUser, error: error);

  bool get isAuthenticated => domainUser != null;
  bool get hasError => error != null;
}

/// Offline authentication service
class OfflineAuthService {
  static const String _lastUserKey = 'last_authenticated_user';
  static const String _cachedCredentialsKey = 'cached_credentials';

  final LocalDatabaseService _localDatabase;
  final ConnectivityService _connectivityService;

  OfflineAuthService({
    required LocalDatabaseService localDatabase,
    required ConnectivityService connectivityService,
  }) : _localDatabase = localDatabase,
       _connectivityService = connectivityService;

  /// Cache user session for offline access
  Future<void> cacheUserSession({
    required firebase_auth.User firebaseUser,
    required domain.User domainUser,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Cache Firebase user data
      final userData = {
        'uid': firebaseUser.uid,
        'email': firebaseUser.email,
        'email_verified': firebaseUser.emailVerified,
        'display_name': firebaseUser.displayName,
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_lastUserKey, jsonEncode(userData));

      // Cache domain user in local database
      await _localDatabase.cacheUser(UserModel.fromEntity(domainUser));
    } catch (e) {
      // Ignore caching errors
    }
  }

  /// Restore user session from cache
  Future<OfflineAuthState?> restoreUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedUserData = prefs.getString(_lastUserKey);

      if (cachedUserData == null) return null;

      final userData = jsonDecode(cachedUserData) as Map<String, dynamic>;
      final uid = userData['uid'] as String;

      // Get cached user profile from local database
      final cachedUser = await _localDatabase.getCachedUser(uid);
      if (cachedUser == null) return null;

      // Check if cache is not too old (e.g., 30 days)
      final cachedAt = userData['cached_at'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      const thirtyDays = 30 * 24 * 60 * 60 * 1000;

      if (now - cachedAt > thirtyDays) {
        await clearUserSession();
        return null;
      }

      return OfflineAuthState.authenticatedOffline(
        email: userData['email'] as String,
        domainUser: cachedUser.toEntity(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if user can login offline with provided credentials
  Future<bool> canLoginOffline(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedCredentials = prefs.getString(_cachedCredentialsKey);

      if (cachedCredentials == null) return false;

      final credMap = jsonDecode(cachedCredentials) as Map<String, dynamic>;
      final cachedEmail = credMap['email'] as String?;
      final cachedPasswordHash = credMap['password_hash'] as String?;

      return cachedEmail == email &&
          cachedPasswordHash == _hashPassword(password);
    } catch (e) {
      return false;
    }
  }

  /// Cache login credentials for offline verification
  Future<void> cacheLoginCredentials({
    required String uid,
    required String email,
    required String password,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final credentialsData = {
        'uid': uid,
        'email': email,
        'password_hash': _hashPassword(password),
        'cached_at': DateTime.now().millisecondsSinceEpoch,
      };

      await prefs.setString(_cachedCredentialsKey, jsonEncode(credentialsData));
    } catch (e) {
      // Ignore caching errors
    }
  }

  /// Clear user session cache
  Future<void> clearUserSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastUserKey);
      await prefs.remove(_cachedCredentialsKey);
    } catch (e) {
      // Ignore errors
    }
  }

  /// Check if device is currently online
  Future<bool> get isOnline => _connectivityService.isConnected;

  /// Simple password hashing (use proper hashing in production)
  String _hashPassword(String password) {
    // This is a simple hash for demo purposes
    // In production, use proper password hashing like bcrypt or Argon2
    return password.hashCode.toString();
  }
}

/// Provider for offline auth service
final offlineAuthServiceProvider = Provider<OfflineAuthService>((ref) {
  return OfflineAuthService(
    localDatabase: ref.watch(localDatabaseProvider),
    connectivityService: ref.watch(connectivityServiceProvider),
  );
});

/// Provider for checking if user can work offline
final canWorkOfflineProvider = FutureProvider<bool>((ref) async {
  final offlineAuthService = ref.watch(offlineAuthServiceProvider);
  final cachedSession = await offlineAuthService.restoreUserSession();
  return cachedSession != null;
});

/// Provider for cached user session
final cachedUserSessionProvider = FutureProvider<OfflineAuthState?>((
  ref,
) async {
  final offlineAuthService = ref.watch(offlineAuthServiceProvider);
  return await offlineAuthService.restoreUserSession();
});

/// Enhanced auth state that includes offline capabilities
final enhancedAuthStateProvider = Provider<OfflineAuthState>((ref) {
  final regularAuthState = ref.watch(authProvider);

  // Handle loading state first
  if (regularAuthState.isLoading) {
    return const OfflineAuthState.loading();
  }

  // Handle authenticated state
  if (regularAuthState.domainUser != null) {
    return OfflineAuthState.authenticated(
      firebaseUser: regularAuthState.firebaseUser!,
      domainUser: regularAuthState.domainUser!,
    );
  }

  // Handle unauthenticated state - try offline mode
  final isConnected = ref.watch(isConnectedProvider);

  // Only try offline if we're explicitly offline
  if (isConnected.hasValue && isConnected.value == false) {
    final cachedSession = ref.watch(cachedUserSessionProvider);
    if (cachedSession.hasValue && cachedSession.value != null) {
      return cachedSession.value!;
    }
  }

  // Default to unauthenticated
  return const OfflineAuthState.unauthenticated();
});

/// Convenience providers for offline auth
final isOfflineAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(enhancedAuthStateProvider);
  return authState.isAuthenticated;
});

final currentOfflineUserProvider = Provider<domain.User?>((ref) {
  final authState = ref.watch(enhancedAuthStateProvider);
  return authState.domainUser;
});

final isOfflineModeProvider = Provider<bool>((ref) {
  final authState = ref.watch(enhancedAuthStateProvider);
  return authState.isOfflineMode;
});
