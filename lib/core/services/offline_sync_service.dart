import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/remote/user_remote_datasource.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_status.dart';
import '../../presentation/providers/auth_provider.dart';
import 'connectivity_service.dart';
import 'local_database_service.dart';

/// Service for handling offline data synchronization
class OfflineSyncService {
  final ConnectivityService _connectivityService;
  final LocalDatabaseService _localDatabaseService;
  final UserRemoteDataSource _userRemoteDataSource;

  OfflineSyncService({
    required ConnectivityService connectivityService,
    required LocalDatabaseService localDatabaseService,
    required UserRemoteDataSource userRemoteDataSource,
  }) : _connectivityService = connectivityService,
       _localDatabaseService = localDatabaseService,
       _userRemoteDataSource = userRemoteDataSource;

  StreamSubscription<bool>? _connectivitySubscription;
  bool _isSyncing = false;

  /// Initialize sync service and start monitoring connectivity
  void initialize() {
    _connectivitySubscription = _connectivityService.connectivityStream.listen((
      isConnected,
    ) {
      if (isConnected && !_isSyncing) {
        _performSync();
      }
    });
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }

  /// Check if currently syncing
  bool get isSyncing => _isSyncing;

  /// Perform full synchronization when connection is available
  Future<SyncResult> _performSync() async {
    if (_isSyncing) return SyncResult.alreadyInProgress;

    _isSyncing = true;
    final results = <SyncOperationResult>[];

    try {
      // Get pending sync operations
      final pendingOperations = await _localDatabaseService
          .getPendingSyncOperations();

      if (pendingOperations.isEmpty) {
        _isSyncing = false;
        return SyncResult.noOperationsPending;
      }

      // Process each operation
      for (final operation in pendingOperations) {
        if (operation.retryCount >= 3) {
          // Skip operations that have failed too many times
          results.add(
            SyncOperationResult(
              operation: operation,
              success: false,
              error: 'Maximum retry count exceeded',
            ),
          );
          continue;
        }

        try {
          await _processSyncOperation(operation);
          await _localDatabaseService.removeSyncOperation(operation.id);
          results.add(SyncOperationResult(operation: operation, success: true));
        } catch (e) {
          await _localDatabaseService.incrementRetryCount(operation.id);
          results.add(
            SyncOperationResult(
              operation: operation,
              success: false,
              error: e.toString(),
            ),
          );
        }
      }

      _isSyncing = false;

      final successCount = results.where((r) => r.success).length;
      final failureCount = results.where((r) => !r.success).length;

      if (failureCount == 0) {
        return SyncResult.allSuccess;
      } else if (successCount > 0) {
        return SyncResult.partialSuccess;
      } else {
        return SyncResult.allFailed;
      }
    } catch (e) {
      _isSyncing = false;
      return SyncResult.syncError;
    }
  }

  /// Process a single sync operation
  Future<void> _processSyncOperation(SyncOperation operation) async {
    switch (operation.operationType) {
      case SyncOperationType.createUser:
        await _userRemoteDataSource.createUserProfile(
          uid: operation.data['uid'] as String,
          email: operation.data['email'] as String,
          name: operation.data['name'] as String,
        );
        break;

      case SyncOperationType.updateUser:
        await _userRemoteDataSource.updateUserProfile(
          uid: operation.data['uid'] as String,
          name: operation.data['name'] as String?,
          email: operation.data['email'] as String?,
        );
        break;

      case SyncOperationType.updateUserStatus:
        await _userRemoteDataSource.updateUserStatus(
          targetUid: operation.data['targetUid'] as String,
          newStatus: UserStatus.values.firstWhere(
            (status) => status.value == operation.data['newStatus'],
          ),
        );
        break;

      case SyncOperationType.updateUserRole:
        await _userRemoteDataSource.updateUserRole(
          targetUid: operation.data['targetUid'] as String,
          newRole: UserRole.values.firstWhere(
            (role) => role.value == operation.data['newRole'],
          ),
        );
        break;

      case SyncOperationType.deleteUser:
        await _userRemoteDataSource.deleteUser(operation.data['uid'] as String);
        break;
    }
  }

  /// Force sync when user requests it
  Future<SyncResult> forcSync() async {
    if (!await _connectivityService.isConnected) {
      return SyncResult.noConnection;
    }

    return await _performSync();
  }

  /// Cache user data for offline access
  Future<void> cacheUserData(UserModel user) async {
    await _localDatabaseService.cacheUser(user);
  }

  /// Cache multiple users for offline access
  Future<void> cacheUsersData(List<UserModel> users) async {
    await _localDatabaseService.cacheUsers(users);
  }

  /// Get cached user data
  Future<UserModel?> getCachedUser(String uid) async {
    return await _localDatabaseService.getCachedUser(uid);
  }

  /// Get all cached users
  Future<List<UserModel>> getCachedUsers() async {
    return await _localDatabaseService.getCachedUsers();
  }

  /// Add operation to sync queue for later execution
  Future<void> queueOfflineOperation({
    required SyncOperationType operationType,
    required Map<String, dynamic> data,
  }) async {
    await _localDatabaseService.addToSyncQueue(
      operationType: operationType,
      data: data,
    );
  }

  /// Get count of pending sync operations
  Future<int> getPendingSyncCount() async {
    final operations = await _localDatabaseService.getPendingSyncOperations();
    return operations.length;
  }

  /// Clear all offline data
  Future<void> clearOfflineData() async {
    await _localDatabaseService.clearAllCache();
  }

  /// Clean up expired cache
  Future<void> cleanupExpiredCache() async {
    await _localDatabaseService.clearExpiredCache();
  }
}

/// Sync operation result
class SyncOperationResult {
  final SyncOperation operation;
  final bool success;
  final String? error;

  SyncOperationResult({
    required this.operation,
    required this.success,
    this.error,
  });
}

/// Overall sync result
enum SyncResult {
  allSuccess,
  partialSuccess,
  allFailed,
  syncError,
  noOperationsPending,
  alreadyInProgress,
  noConnection,
}

extension SyncResultExtension on SyncResult {
  String get message {
    switch (this) {
      case SyncResult.allSuccess:
        return 'All operations synced successfully';
      case SyncResult.partialSuccess:
        return 'Some operations synced successfully';
      case SyncResult.allFailed:
        return 'All sync operations failed';
      case SyncResult.syncError:
        return 'Sync process encountered an error';
      case SyncResult.noOperationsPending:
        return 'No operations pending sync';
      case SyncResult.alreadyInProgress:
        return 'Sync already in progress';
      case SyncResult.noConnection:
        return 'No internet connection available';
    }
  }

  bool get isSuccess =>
      this == SyncResult.allSuccess || this == SyncResult.noOperationsPending;
}

/// Riverpod providers
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  return OfflineSyncService(
    connectivityService: ref.watch(connectivityServiceProvider),
    localDatabaseService: ref.watch(localDatabaseProvider),
    userRemoteDataSource: ref.watch(userRemoteDataSourceProvider),
  );
});

/// Provider for pending sync count
final pendingSyncCountProvider = FutureProvider<int>((ref) async {
  final syncService = ref.watch(offlineSyncServiceProvider);
  return await syncService.getPendingSyncCount();
});

/// Provider for sync status
final syncStatusProvider = NotifierProvider<SyncStatusNotifier, SyncResult?>(
  SyncStatusNotifier.new,
);

class SyncStatusNotifier extends Notifier<SyncResult?> {
  @override
  SyncResult? build() => null;

  void updateStatus(SyncResult? status) {
    state = status;
  }

  void clearStatus() {
    state = null;
  }
}
