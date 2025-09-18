/// User roles enumeration with business logic
enum UserRole {
  admin,
  moderator,
  user;

  /// Check if this role can verify users
  bool get canVerifyUsers =>
      this == UserRole.admin || this == UserRole.moderator;

  /// Check if this role can change user roles
  bool get canChangeRoles => this == UserRole.admin;

  /// Check if this role can delete users
  bool get canDeleteUsers => this == UserRole.admin;

  /// Check if this role can view all users
  bool get canViewAllUsers =>
      this == UserRole.admin || this == UserRole.moderator;

  /// Convert from string representation
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'moderator':
        return UserRole.moderator;
      case 'user':
      default:
        return UserRole.user;
    }
  }

  /// Convert to string representation
  String get value {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.moderator:
        return 'moderator';
      case UserRole.user:
        return 'user';
    }
  }
}
