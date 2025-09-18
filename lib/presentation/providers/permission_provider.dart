import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../domain/entities/app_permission.dart';

/// Provider untuk mengelola app permissions dan privacy settings
/// Menggunakan SharedPreferences untuk persistence dan state management
class PermissionNotifier
    extends AsyncNotifier<Map<AppPermissionType, AppPermission>> {
  static const String _permissionsKey = 'app_permissions';

  @override
  Future<Map<AppPermissionType, AppPermission>> build() async {
    return await _loadPermissions();
  }

  /// Load permissions dari SharedPreferences
  Future<Map<AppPermissionType, AppPermission>> _loadPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final permissionsJson = prefs.getString(_permissionsKey);

      if (permissionsJson != null) {
        final Map<String, dynamic> data = json.decode(permissionsJson);
        final Map<AppPermissionType, AppPermission> permissions = {};

        for (final entry in data.entries) {
          final type = AppPermissionType.values.byName(entry.key);
          permissions[type] = AppPermission.fromJson(entry.value);
        }

        return permissions;
      }
    } catch (e) {
      debugPrint('Error loading permissions: $e');
    }

    // Return default permissions if loading fails
    return _getDefaultPermissions();
  }

  /// Save permissions ke SharedPreferences
  Future<void> _savePermissions(
    Map<AppPermissionType, AppPermission> permissions,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> data = {};

      for (final entry in permissions.entries) {
        data[entry.key.name] = entry.value.toJson();
      }

      await prefs.setString(_permissionsKey, json.encode(data));
    } catch (e) {
      debugPrint('Error saving permissions: $e');
    }
  }

  /// Default permissions state
  Map<AppPermissionType, AppPermission> _getDefaultPermissions() {
    final Map<AppPermissionType, AppPermission> permissions = {};

    for (final type in AppPermissionType.values) {
      permissions[type] = AppPermission(
        type: type,
        status: PermissionStatus.notRequested,
        lastRequested: null,
        lastChanged: DateTime.now(),
      );
    }

    return permissions;
  }

  /// Update status permission tertentu
  Future<void> updatePermissionStatus({
    required AppPermissionType type,
    required PermissionStatus status,
    String? reasonDenied,
  }) async {
    final currentState = await future;
    final currentPermission = currentState[type];

    if (currentPermission == null) return;

    final updatedPermission = currentPermission.copyWith(
      status: status,
      lastChanged: DateTime.now(),
      lastRequested: DateTime.now(),
      reasonDenied: reasonDenied,
    );

    final updatedPermissions = Map<AppPermissionType, AppPermission>.from(
      currentState,
    );
    updatedPermissions[type] = updatedPermission;

    state = AsyncValue.data(updatedPermissions);
    await _savePermissions(updatedPermissions);
  }

  /// Request permission (simulasi - dalam real app akan integrate dengan permission_handler)
  Future<PermissionStatus> requestPermission(AppPermissionType type) async {
    final currentState = await future;
    final currentPermission = currentState[type];

    if (currentPermission?.status == PermissionStatus.permanentlyDenied) {
      return PermissionStatus.permanentlyDenied;
    }

    // Simulasi permission request
    // Dalam real implementation, gunakan permission_handler package
    PermissionStatus newStatus;

    // Simulasi: 80% chance granted, 15% denied, 5% permanently denied
    final random = DateTime.now().millisecondsSinceEpoch % 100;
    if (random < 80) {
      newStatus = PermissionStatus.granted;
    } else if (random < 95) {
      newStatus = PermissionStatus.denied;
    } else {
      newStatus = PermissionStatus.permanentlyDenied;
    }

    await updatePermissionStatus(
      type: type,
      status: newStatus,
      reasonDenied: newStatus == PermissionStatus.denied
          ? 'User denied permission request'
          : null,
    );

    return newStatus;
  }

  /// Check apakah permission sudah granted
  bool isPermissionGranted(AppPermissionType type) {
    final currentState = state.value;
    if (currentState == null) return false;

    final permission = currentState[type];
    return permission?.status == PermissionStatus.granted;
  }

  /// Get critical permissions yang belum granted
  List<AppPermissionType> getCriticalPermissionsDenied() {
    final currentState = state.value;
    if (currentState == null) return [];

    return AppPermissionType.values.where((type) => type.isCritical).where((
      type,
    ) {
      final permission = currentState[type];
      return permission?.status != PermissionStatus.granted;
    }).toList();
  }

  /// Reset semua permissions ke default state
  Future<void> resetAllPermissions() async {
    final defaultPermissions = _getDefaultPermissions();
    state = AsyncValue.data(defaultPermissions);
    await _savePermissions(defaultPermissions);
  }

  /// Get permissions by status
  List<AppPermission> getPermissionsByStatus(PermissionStatus status) {
    final currentState = state.value;
    if (currentState == null) return [];

    return currentState.values
        .where((permission) => permission.status == status)
        .toList();
  }
}

/// Provider untuk permission notifier
final permissionProvider =
    AsyncNotifierProvider<
      PermissionNotifier,
      Map<AppPermissionType, AppPermission>
    >(() {
      return PermissionNotifier();
    });

/// Convenience provider untuk cek status permission tertentu
final permissionStatusProvider =
    Provider.family<PermissionStatus?, AppPermissionType>((ref, type) {
      final permissionsAsync = ref.watch(permissionProvider);

      return permissionsAsync.when(
        data: (permissions) => permissions[type]?.status,
        loading: () => null,
        error: (_, _) => null,
      );
    });

/// Provider untuk cek apakah permission granted
final isPermissionGrantedProvider = Provider.family<bool, AppPermissionType>((
  ref,
  type,
) {
  final status = ref.watch(permissionStatusProvider(type));
  return status == PermissionStatus.granted;
});

/// Provider untuk critical permissions yang belum granted
final criticalPermissionsDeniedProvider = Provider<List<AppPermissionType>>((
  ref,
) {
  final permissionsAsync = ref.watch(permissionProvider);

  return permissionsAsync.when(
    data: (permissions) {
      return AppPermissionType.values.where((type) => type.isCritical).where((
        type,
      ) {
        final permission = permissions[type];
        return permission?.status != PermissionStatus.granted;
      }).toList();
    },
    loading: () => [],
    error: (_, _) => [],
  );
});

/// Provider untuk permission summary stats
final permissionSummaryProvider = Provider<Map<String, int>>((ref) {
  final permissionsAsync = ref.watch(permissionProvider);

  return permissionsAsync.when(
    data: (permissions) {
      final summary = <String, int>{
        'total': permissions.length,
        'granted': 0,
        'denied': 0,
        'notRequested': 0,
        'permanentlyDenied': 0,
      };

      for (final permission in permissions.values) {
        switch (permission.status) {
          case PermissionStatus.granted:
            summary['granted'] = (summary['granted'] ?? 0) + 1;
            break;
          case PermissionStatus.denied:
            summary['denied'] = (summary['denied'] ?? 0) + 1;
            break;
          case PermissionStatus.notRequested:
            summary['notRequested'] = (summary['notRequested'] ?? 0) + 1;
            break;
          case PermissionStatus.permanentlyDenied:
            summary['permanentlyDenied'] =
                (summary['permanentlyDenied'] ?? 0) + 1;
            break;
          case PermissionStatus.restricted:
            // Count as denied for simplicity
            summary['denied'] = (summary['denied'] ?? 0) + 1;
            break;
        }
      }

      return summary;
    },
    loading: () => {
      'total': 0,
      'granted': 0,
      'denied': 0,
      'notRequested': 0,
      'permanentlyDenied': 0,
    },
    error: (_, _) => {
      'total': 0,
      'granted': 0,
      'denied': 0,
      'notRequested': 0,
      'permanentlyDenied': 0,
    },
  );
});
