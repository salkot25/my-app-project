import 'package:either_dart/either.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/failures.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/offline_sync_service.dart';
import '../../core/services/local_database_service.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_status.dart';
import '../../domain/repositories/user_repository.dart';
import '../../data/models/user_model.dart';
import '../datasources/remote/user_remote_datasource.dart';
import '../../presentation/providers/auth_provider.dart';

/// Offline-first implementation of UserRepository
/// This repository prioritizes cached data and falls back to network when needed
class OfflineFirstUserRepository implements UserRepository {
  final UserRemoteDataSource _userRemoteDataSource;
  final OfflineSyncService _offlineSyncService;
  final ConnectivityService _connectivityService;

  const OfflineFirstUserRepository({
    required UserRemoteDataSource userRemoteDataSource,
    required OfflineSyncService offlineSyncService,
    required ConnectivityService connectivityService,
  }) : _userRemoteDataSource = userRemoteDataSource,
       _offlineSyncService = offlineSyncService,
       _connectivityService = connectivityService;

  @override
  Future<Either<FirestoreFailure, User>> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Online: Create directly
        final userModel = await _userRemoteDataSource.createUserProfile(
          uid: uid,
          email: email,
          name: name,
        );

        // Cache the created user
        await _offlineSyncService.cacheUserData(userModel);

        return Right(userModel.toEntity());
      } else {
        // Offline: Queue for sync and create local entry
        await _offlineSyncService.queueOfflineOperation(
          operationType: SyncOperationType.createUser,
          data: {'uid': uid, 'email': email, 'name': name},
        );

        // Create temporary local user
        final userModel = UserModel(
          uid: uid,
          email: email,
          name: name,
          role: UserRole.user,
          status: UserStatus.unverified,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _offlineSyncService.cacheUserData(userModel);
        return Right(userModel.toEntity());
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> getUserProfile(String uid) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Online: Fetch from network and cache
        try {
          final userModel = await _userRemoteDataSource.getUserProfile(uid);
          await _offlineSyncService.cacheUserData(userModel);
          return Right(userModel.toEntity());
        } catch (e) {
          // Network failed, try cache
          final cachedUser = await _offlineSyncService.getCachedUser(uid);
          if (cachedUser != null) {
            return Right(cachedUser.toEntity());
          }
          rethrow;
        }
      } else {
        // Offline: Use cached data only
        final cachedUser = await _offlineSyncService.getCachedUser(uid);
        if (cachedUser != null) {
          return Right(cachedUser.toEntity());
        } else {
          return const Left(FirestoreFailure.notFound());
        }
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> updateUserProfile({
    required String uid,
    required String currentUserUid,
    String? name,
    String? email,
  }) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Online: Update directly
        final userModel = await _userRemoteDataSource.updateUserProfile(
          uid: uid,
          name: name,
          email: email,
        );

        // Cache the updated user
        await _offlineSyncService.cacheUserData(userModel);

        return Right(userModel.toEntity());
      } else {
        // Offline: Queue for sync and update local cache
        await _offlineSyncService.queueOfflineOperation(
          operationType: SyncOperationType.updateUser,
          data: {'uid': uid, 'name': name, 'email': email},
        );

        // Update cached user if exists
        final cachedUser = await _offlineSyncService.getCachedUser(uid);
        if (cachedUser != null) {
          final updatedUser = UserModel(
            uid: cachedUser.uid,
            email: email ?? cachedUser.email,
            name: name ?? cachedUser.name,
            role: cachedUser.role,
            status: cachedUser.status,
            createdAt: cachedUser.createdAt,
            updatedAt: DateTime.now(),
          );

          await _offlineSyncService.cacheUserData(updatedUser);
          return Right(updatedUser.toEntity());
        } else {
          return const Left(FirestoreFailure.notFound());
        }
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> updateUserStatus({
    required String targetUid,
    required String currentUserUid,
    required UserStatus newStatus,
  }) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Check permissions first from cache or network
        final currentUserResult = await getUserProfile(currentUserUid);
        if (currentUserResult.isLeft) return currentUserResult;

        final currentUser = currentUserResult.right;
        if (!currentUser.canVerifyUsers) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        // Online: Update directly
        final userModel = await _userRemoteDataSource.updateUserStatus(
          targetUid: targetUid,
          newStatus: newStatus,
        );

        await _offlineSyncService.cacheUserData(userModel);
        return Right(userModel.toEntity());
      } else {
        // Offline: Check cached permissions and queue
        final cachedCurrentUser = await _offlineSyncService.getCachedUser(
          currentUserUid,
        );
        if (cachedCurrentUser == null ||
            !cachedCurrentUser.toEntity().canVerifyUsers) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        await _offlineSyncService.queueOfflineOperation(
          operationType: SyncOperationType.updateUserStatus,
          data: {'targetUid': targetUid, 'newStatus': newStatus.value},
        );

        // Update cached user
        final cachedUser = await _offlineSyncService.getCachedUser(targetUid);
        if (cachedUser != null) {
          final updatedUser = UserModel(
            uid: cachedUser.uid,
            email: cachedUser.email,
            name: cachedUser.name,
            role: cachedUser.role,
            status: newStatus,
            createdAt: cachedUser.createdAt,
            updatedAt: DateTime.now(),
          );

          await _offlineSyncService.cacheUserData(updatedUser);
          return Right(updatedUser.toEntity());
        } else {
          return const Left(FirestoreFailure.notFound());
        }
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> updateUserRole({
    required String targetUid,
    required String currentUserUid,
    required UserRole newRole,
  }) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Check permissions first
        final currentUserResult = await getUserProfile(currentUserUid);
        if (currentUserResult.isLeft) return currentUserResult;

        final currentUser = currentUserResult.right;
        if (!currentUser.canChangeRoles) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        final userModel = await _userRemoteDataSource.updateUserRole(
          targetUid: targetUid,
          newRole: newRole,
        );

        await _offlineSyncService.cacheUserData(userModel);
        return Right(userModel.toEntity());
      } else {
        // Offline: Check cached permissions and queue
        final cachedCurrentUser = await _offlineSyncService.getCachedUser(
          currentUserUid,
        );
        if (cachedCurrentUser == null ||
            !cachedCurrentUser.toEntity().canChangeRoles) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        await _offlineSyncService.queueOfflineOperation(
          operationType: SyncOperationType.updateUserRole,
          data: {'targetUid': targetUid, 'newRole': newRole.value},
        );

        // Update cached user
        final cachedUser = await _offlineSyncService.getCachedUser(targetUid);
        if (cachedUser != null) {
          final updatedUser = UserModel(
            uid: cachedUser.uid,
            email: cachedUser.email,
            name: cachedUser.name,
            role: newRole,
            status: cachedUser.status,
            createdAt: cachedUser.createdAt,
            updatedAt: DateTime.now(),
          );

          await _offlineSyncService.cacheUserData(updatedUser);
          return Right(updatedUser.toEntity());
        } else {
          return const Left(FirestoreFailure.notFound());
        }
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, List<User>>> getAllUsers(
    String currentUserUid,
  ) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Check permissions first
        final currentUserResult = await getUserProfile(currentUserUid);
        if (currentUserResult.isLeft) {
          return Left(currentUserResult.left);
        }

        final currentUser = currentUserResult.right;
        if (!currentUser.canViewAllUsers) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        // Online: Fetch from network and cache
        try {
          final userModels = await _userRemoteDataSource.getAllUsers();
          await _offlineSyncService.cacheUsersData(userModels);
          final users = userModels.map((model) => model.toEntity()).toList();
          return Right(users);
        } catch (e) {
          // Network failed, try cache
          final cachedUsers = await _offlineSyncService.getCachedUsers();
          if (cachedUsers.isNotEmpty) {
            final users = cachedUsers.map((model) => model.toEntity()).toList();
            return Right(users);
          }
          rethrow;
        }
      } else {
        // Offline: Check cached permissions and return cached data
        final cachedCurrentUser = await _offlineSyncService.getCachedUser(
          currentUserUid,
        );
        if (cachedCurrentUser == null ||
            !cachedCurrentUser.toEntity().canViewAllUsers) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        final cachedUsers = await _offlineSyncService.getCachedUsers();
        final users = cachedUsers.map((model) => model.toEntity()).toList();
        return Right(users);
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, void>> deleteUser({
    required String targetUid,
    required String currentUserUid,
  }) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Check permissions first
        final currentUserResult = await getUserProfile(currentUserUid);
        if (currentUserResult.isLeft) {
          return Left(currentUserResult.left);
        }

        final currentUser = currentUserResult.right;
        if (!currentUser.canDeleteUsers) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        await _userRemoteDataSource.deleteUser(targetUid);
        return const Right(null);
      } else {
        // Offline: Check cached permissions and queue
        final cachedCurrentUser = await _offlineSyncService.getCachedUser(
          currentUserUid,
        );
        if (cachedCurrentUser == null ||
            !cachedCurrentUser.toEntity().canDeleteUsers) {
          return const Left(FirestoreFailure.permissionDenied());
        }

        await _offlineSyncService.queueOfflineOperation(
          operationType: SyncOperationType.deleteUser,
          data: {'uid': targetUid},
        );

        return const Right(null);
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Stream<Either<FirestoreFailure, User>> watchUserProfile(String uid) {
    // For offline-first approach, we'll combine cached data with network updates
    return Stream.fromFuture(getUserProfile(uid));
  }

  @override
  Future<Either<FirestoreFailure, bool>> userExists(String uid) async {
    try {
      final isConnected = await _connectivityService.isConnected;

      if (isConnected) {
        // Online: Check network first
        try {
          final exists = await _userRemoteDataSource.userExists(uid);
          return Right(exists);
        } catch (e) {
          // Network failed, check cache
          final cachedUser = await _offlineSyncService.getCachedUser(uid);
          return Right(cachedUser != null);
        }
      } else {
        // Offline: Check cache only
        final cachedUser = await _offlineSyncService.getCachedUser(uid);
        return Right(cachedUser != null);
      }
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }
}

/// Provider for offline-first user repository
final offlineFirstUserRepositoryProvider = Provider<OfflineFirstUserRepository>(
  (ref) {
    return OfflineFirstUserRepository(
      userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
      offlineSyncService: ref.watch(offlineSyncServiceProvider),
      connectivityService: ref.watch(connectivityServiceProvider),
    );
  },
);
