import 'package:flutter/material.dart';

/// App Permission Types untuk privacy dan permission management
/// Mengikuti best practices untuk user privacy dan compliance
enum AppPermissionType {
  camera,
  location,
  microphone,
  photos,
  contacts,
  notifications,
  storage,
  calendar,
  bluetooth,
  phone;

  /// Display name untuk UI
  String get displayName {
    switch (this) {
      case AppPermissionType.camera:
        return 'Camera';
      case AppPermissionType.location:
        return 'Location';
      case AppPermissionType.microphone:
        return 'Microphone';
      case AppPermissionType.photos:
        return 'Photos';
      case AppPermissionType.contacts:
        return 'Contacts';
      case AppPermissionType.notifications:
        return 'Notifications';
      case AppPermissionType.storage:
        return 'Storage';
      case AppPermissionType.calendar:
        return 'Calendar';
      case AppPermissionType.bluetooth:
        return 'Bluetooth';
      case AppPermissionType.phone:
        return 'Phone';
    }
  }

  /// Description yang user-friendly
  String get description {
    switch (this) {
      case AppPermissionType.camera:
        return 'Take photos and record videos for profile pictures';
      case AppPermissionType.location:
        return 'Access your location for location-based features';
      case AppPermissionType.microphone:
        return 'Record audio for voice messages and calls';
      case AppPermissionType.photos:
        return 'Access your photo library to select profile pictures';
      case AppPermissionType.contacts:
        return 'Find friends and sync contacts for easier connections';
      case AppPermissionType.notifications:
        return 'Send push notifications for important updates';
      case AppPermissionType.storage:
        return 'Save and access files on your device';
      case AppPermissionType.calendar:
        return 'Access calendar for scheduling and events';
      case AppPermissionType.bluetooth:
        return 'Connect to Bluetooth devices for enhanced features';
      case AppPermissionType.phone:
        return 'Make calls and access phone features';
    }
  }

  /// Icon yang sesuai untuk setiap permission
  IconData get icon {
    switch (this) {
      case AppPermissionType.camera:
        return Icons.camera_alt_outlined;
      case AppPermissionType.location:
        return Icons.location_on_outlined;
      case AppPermissionType.microphone:
        return Icons.mic_outlined;
      case AppPermissionType.photos:
        return Icons.photo_library_outlined;
      case AppPermissionType.contacts:
        return Icons.contacts_outlined;
      case AppPermissionType.notifications:
        return Icons.notifications_outlined;
      case AppPermissionType.storage:
        return Icons.folder_outlined;
      case AppPermissionType.calendar:
        return Icons.calendar_today_outlined;
      case AppPermissionType.bluetooth:
        return Icons.bluetooth_outlined;
      case AppPermissionType.phone:
        return Icons.phone_outlined;
    }
  }

  /// Apakah permission ini critical untuk app functionality
  bool get isCritical {
    switch (this) {
      case AppPermissionType.notifications:
      case AppPermissionType.storage:
        return true;
      case AppPermissionType.camera:
      case AppPermissionType.location:
      case AppPermissionType.microphone:
      case AppPermissionType.photos:
      case AppPermissionType.contacts:
      case AppPermissionType.calendar:
      case AppPermissionType.bluetooth:
      case AppPermissionType.phone:
        return false;
    }
  }
}

/// Status dari setiap permission
enum PermissionStatus {
  granted,
  denied,
  restricted,
  permanentlyDenied,
  notRequested;

  /// Display name untuk UI
  String get displayName {
    switch (this) {
      case PermissionStatus.granted:
        return 'Granted';
      case PermissionStatus.denied:
        return 'Denied';
      case PermissionStatus.restricted:
        return 'Restricted';
      case PermissionStatus.permanentlyDenied:
        return 'Permanently Denied';
      case PermissionStatus.notRequested:
        return 'Not Requested';
    }
  }

  /// Color untuk status indicator
  Color get statusColor {
    switch (this) {
      case PermissionStatus.granted:
        return const Color(0xFF10B981); // Success green
      case PermissionStatus.denied:
        return const Color(0xFFF59E0B); // Warning orange
      case PermissionStatus.restricted:
        return const Color(0xFF6B7280); // Gray
      case PermissionStatus.permanentlyDenied:
        return const Color(0xFFEF4444); // Error red
      case PermissionStatus.notRequested:
        return const Color(0xFF6B7280); // Gray
    }
  }

  /// Icon untuk status
  IconData get statusIcon {
    switch (this) {
      case PermissionStatus.granted:
        return Icons.check_circle_outlined;
      case PermissionStatus.denied:
        return Icons.block_outlined;
      case PermissionStatus.restricted:
        return Icons.lock_outlined;
      case PermissionStatus.permanentlyDenied:
        return Icons.cancel_outlined;
      case PermissionStatus.notRequested:
        return Icons.help_outline;
    }
  }

  /// Apakah user bisa toggle permission ini
  bool get canToggle {
    switch (this) {
      case PermissionStatus.granted:
      case PermissionStatus.denied:
      case PermissionStatus.notRequested:
        return true;
      case PermissionStatus.restricted:
      case PermissionStatus.permanentlyDenied:
        return false;
    }
  }
}

/// Model untuk App Permission dengan status dan metadata
class AppPermission {
  final AppPermissionType type;
  final PermissionStatus status;
  final DateTime? lastRequested;
  final DateTime? lastChanged;
  final String? reasonDenied;

  const AppPermission({
    required this.type,
    required this.status,
    this.lastRequested,
    this.lastChanged,
    this.reasonDenied,
  });

  /// Copy with method untuk state updates
  AppPermission copyWith({
    AppPermissionType? type,
    PermissionStatus? status,
    DateTime? lastRequested,
    DateTime? lastChanged,
    String? reasonDenied,
  }) {
    return AppPermission(
      type: type ?? this.type,
      status: status ?? this.status,
      lastRequested: lastRequested ?? this.lastRequested,
      lastChanged: lastChanged ?? this.lastChanged,
      reasonDenied: reasonDenied ?? this.reasonDenied,
    );
  }

  /// JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'status': status.name,
      'lastRequested': lastRequested?.toIso8601String(),
      'lastChanged': lastChanged?.toIso8601String(),
      'reasonDenied': reasonDenied,
    };
  }

  /// JSON deserialization
  factory AppPermission.fromJson(Map<String, dynamic> json) {
    return AppPermission(
      type: AppPermissionType.values.byName(json['type']),
      status: PermissionStatus.values.byName(json['status']),
      lastRequested: json['lastRequested'] != null
          ? DateTime.parse(json['lastRequested'])
          : null,
      lastChanged: json['lastChanged'] != null
          ? DateTime.parse(json['lastChanged'])
          : null,
      reasonDenied: json['reasonDenied'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppPermission &&
        other.type == type &&
        other.status == status &&
        other.lastRequested == lastRequested &&
        other.lastChanged == lastChanged &&
        other.reasonDenied == reasonDenied;
  }

  @override
  int get hashCode {
    return type.hashCode ^
        status.hashCode ^
        lastRequested.hashCode ^
        lastChanged.hashCode ^
        reasonDenied.hashCode;
  }

  @override
  String toString() {
    return 'AppPermission(type: $type, status: $status, lastRequested: $lastRequested, lastChanged: $lastChanged, reasonDenied: $reasonDenied)';
  }
}
