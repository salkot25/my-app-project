import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_status.dart';

/// Local database service for offline data storage
class LocalDatabaseService {
  static const String _databaseName = 'my_project_offline.db';
  static const int _databaseVersion = 1;

  // Table names
  static const String _usersTable = 'users';
  static const String _syncQueueTable = 'sync_queue';
  static const String _authCacheTable = 'auth_cache';

  Database? _database;

  /// Get database instance
  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  /// Initialize database with tables
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Create database tables
  Future<void> _onCreate(Database db, int version) async {
    // Users table for caching user data
    await db.execute('''
      CREATE TABLE $_usersTable (
        uid TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL,
        cached_at INTEGER NOT NULL
      )
    ''');

    // Sync queue for offline operations
    await db.execute('''
      CREATE TABLE $_syncQueueTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation_type TEXT NOT NULL,
        data TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        retry_count INTEGER DEFAULT 0
      )
    ''');

    // Auth cache for offline authentication
    await db.execute('''
      CREATE TABLE $_authCacheTable (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL,
        expires_at INTEGER,
        created_at INTEGER NOT NULL
      )
    ''');
  }

  /// Handle database upgrades
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database schema changes
  }

  /// Cache user data
  Future<void> cacheUser(UserModel user) async {
    final db = await database;
    await db.insert(_usersTable, {
      'uid': user.uid,
      'email': user.email,
      'name': user.name,
      'role': user.role.value,
      'status': user.status.value,
      'created_at': user.createdAt.millisecondsSinceEpoch,
      'updated_at': user.updatedAt.millisecondsSinceEpoch,
      'cached_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Cache multiple users
  Future<void> cacheUsers(List<UserModel> users) async {
    final db = await database;
    final batch = db.batch();
    final now = DateTime.now().millisecondsSinceEpoch;

    for (final user in users) {
      batch.insert(_usersTable, {
        'uid': user.uid,
        'email': user.email,
        'name': user.name,
        'role': user.role.value,
        'status': user.status.value,
        'created_at': user.createdAt.millisecondsSinceEpoch,
        'updated_at': user.updatedAt.millisecondsSinceEpoch,
        'cached_at': now,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }

    await batch.commit(noResult: true);
  }

  /// Get cached user by UID
  Future<UserModel?> getCachedUser(String uid) async {
    final db = await database;
    final maps = await db.query(
      _usersTable,
      where: 'uid = ?',
      whereArgs: [uid],
    );

    if (maps.isEmpty) return null;

    return _mapToUserModel(maps.first);
  }

  /// Get all cached users
  Future<List<UserModel>> getCachedUsers() async {
    final db = await database;
    final maps = await db.query(_usersTable, orderBy: 'created_at DESC');

    return maps.map(_mapToUserModel).toList();
  }

  /// Convert database map to UserModel
  UserModel _mapToUserModel(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      role: UserRole.values.firstWhere(
        (role) => role.value == map['role'],
        orElse: () => UserRole.user,
      ),
      status: UserStatus.values.firstWhere(
        (status) => status.value == map['status'],
        orElse: () => UserStatus.unverified,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  /// Add operation to sync queue
  Future<void> addToSyncQueue({
    required SyncOperationType operationType,
    required Map<String, dynamic> data,
  }) async {
    final db = await database;
    await db.insert(_syncQueueTable, {
      'operation_type': operationType.name,
      'data': jsonEncode(data),
      'created_at': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    });
  }

  /// Get pending sync operations
  Future<List<SyncOperation>> getPendingSyncOperations() async {
    final db = await database;
    final maps = await db.query(_syncQueueTable, orderBy: 'created_at ASC');

    return maps
        .map(
          (map) => SyncOperation(
            id: map['id'] as int,
            operationType: SyncOperationType.values.firstWhere(
              (type) => type.name == map['operation_type'],
            ),
            data: jsonDecode(map['data'] as String) as Map<String, dynamic>,
            createdAt: DateTime.fromMillisecondsSinceEpoch(
              map['created_at'] as int,
            ),
            retryCount: map['retry_count'] as int,
          ),
        )
        .toList();
  }

  /// Remove sync operation from queue
  Future<void> removeSyncOperation(int id) async {
    final db = await database;
    await db.delete(_syncQueueTable, where: 'id = ?', whereArgs: [id]);
  }

  /// Increment retry count for sync operation
  Future<void> incrementRetryCount(int id) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE $_syncQueueTable SET retry_count = retry_count + 1 WHERE id = ?',
      [id],
    );
  }

  /// Cache authentication data
  Future<void> cacheAuthData(
    String key,
    String value, {
    Duration? expiresIn,
  }) async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;
    final expiresAt = expiresIn != null ? now + expiresIn.inMilliseconds : null;

    await db.insert(_authCacheTable, {
      'key': key,
      'value': value,
      'expires_at': expiresAt,
      'created_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Get cached authentication data
  Future<String?> getCachedAuthData(String key) async {
    final db = await database;
    final maps = await db.query(
      _authCacheTable,
      where: 'key = ?',
      whereArgs: [key],
    );

    if (maps.isEmpty) return null;

    final map = maps.first;
    final expiresAt = map['expires_at'] as int?;

    // Check if expired
    if (expiresAt != null &&
        DateTime.now().millisecondsSinceEpoch > expiresAt) {
      await db.delete(_authCacheTable, where: 'key = ?', whereArgs: [key]);
      return null;
    }

    return map['value'] as String;
  }

  /// Clear expired cache entries
  Future<void> clearExpiredCache() async {
    final db = await database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.delete(
      _authCacheTable,
      where: 'expires_at IS NOT NULL AND expires_at < ?',
      whereArgs: [now],
    );

    // Remove old cached users (older than 30 days)
    final thirtyDaysAgo = now - (30 * 24 * 60 * 60 * 1000);
    await db.delete(
      _usersTable,
      where: 'cached_at < ?',
      whereArgs: [thirtyDaysAgo],
    );
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    final db = await database;
    await db.delete(_usersTable);
    await db.delete(_authCacheTable);
    await db.delete(_syncQueueTable);
  }

  /// Close database connection
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

/// Sync operation types
enum SyncOperationType {
  createUser,
  updateUser,
  updateUserStatus,
  updateUserRole,
  deleteUser,
}

/// Sync operation model
class SyncOperation {
  final int id;
  final SyncOperationType operationType;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  const SyncOperation({
    required this.id,
    required this.operationType,
    required this.data,
    required this.createdAt,
    required this.retryCount,
  });
}

/// Riverpod provider for local database
final localDatabaseProvider = Provider<LocalDatabaseService>((ref) {
  return LocalDatabaseService();
});
