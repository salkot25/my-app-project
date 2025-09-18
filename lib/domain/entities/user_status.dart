/// User status enumeration with business logic
enum UserStatus {
  verified,
  unverified,
  suspended;

  /// Check if user can access the application
  bool get canAccessApp => this == UserStatus.verified;

  /// Convert from string representation
  static UserStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return UserStatus.verified;
      case 'suspended':
        return UserStatus.suspended;
      case 'unverified':
      default:
        return UserStatus.unverified;
    }
  }

  /// Convert to string representation
  String get value {
    switch (this) {
      case UserStatus.verified:
        return 'verified';
      case UserStatus.unverified:
        return 'unverified';
      case UserStatus.suspended:
        return 'suspended';
    }
  }
}
