import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for monitoring network connectivity status
class ConnectivityService {
  ConnectivityService._();
  static final instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();

  /// Check current connectivity status
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any(
      (connectivity) =>
          connectivity == ConnectivityResult.mobile ||
          connectivity == ConnectivityResult.wifi ||
          connectivity == ConnectivityResult.ethernet,
    );
  }

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((results) {
      return results.any(
        (result) =>
            result == ConnectivityResult.mobile ||
            result == ConnectivityResult.wifi ||
            result == ConnectivityResult.ethernet,
      );
    });
  }

  /// Get detailed connectivity information
  Future<ConnectivityStatus> get connectivityStatus async {
    final results = await _connectivity.checkConnectivity();

    if (results.contains(ConnectivityResult.wifi)) {
      return ConnectivityStatus.wifi;
    } else if (results.contains(ConnectivityResult.mobile)) {
      return ConnectivityStatus.mobile;
    } else if (results.contains(ConnectivityResult.ethernet)) {
      return ConnectivityStatus.ethernet;
    } else {
      return ConnectivityStatus.none;
    }
  }

  /// Stream of detailed connectivity status
  Stream<ConnectivityStatus> get connectivityStatusStream {
    return _connectivity.onConnectivityChanged.map((results) {
      if (results.contains(ConnectivityResult.wifi)) {
        return ConnectivityStatus.wifi;
      } else if (results.contains(ConnectivityResult.mobile)) {
        return ConnectivityStatus.mobile;
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return ConnectivityStatus.ethernet;
      } else {
        return ConnectivityStatus.none;
      }
    });
  }
}

/// Connectivity status enum
enum ConnectivityStatus {
  wifi,
  mobile,
  ethernet,
  none;

  bool get isConnected => this != ConnectivityStatus.none;

  String get displayName {
    switch (this) {
      case ConnectivityStatus.wifi:
        return 'Wi-Fi';
      case ConnectivityStatus.mobile:
        return 'Mobile Data';
      case ConnectivityStatus.ethernet:
        return 'Ethernet';
      case ConnectivityStatus.none:
        return 'No Connection';
    }
  }
}

/// Riverpod providers for connectivity
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService.instance;
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStatusStream;
});

final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Simple provider that gets current connectivity status synchronously
final currentConnectivityProvider = FutureProvider<ConnectivityStatus>((
  ref,
) async {
  final service = ref.watch(connectivityServiceProvider);
  return await service.connectivityStatus;
});
