import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';

/// User entity representing a user in the domain layer
class User extends Equatable {
  const User({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uid;
  final String email;
  final String name;
  final UserRole role;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Check if this user can verify other users
  bool get canVerifyUsers => role.canVerifyUsers;

  /// Check if this user can change roles of other users
  bool get canChangeRoles => role.canChangeRoles;

  /// Check if this user can delete other users
  bool get canDeleteUsers => role.canDeleteUsers;

  /// Check if this user can view all users
  bool get canViewAllUsers => role.canViewAllUsers;

  /// Check if this user can access the application
  bool get canAccessApp => status.canAccessApp;

  /// Check if this user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if this user is a moderator
  bool get isModerator => role == UserRole.moderator;

  /// Check if this user is verified
  bool get isVerified => status == UserStatus.verified;

  /// Check if this user is suspended
  bool get isSuspended => status == UserStatus.suspended;

  /// Create a copy of this user with updated fields
  User copyWith({
    String? uid,
    String? email,
    String? name,
    UserRole? role,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    name,
    role,
    status,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() {
    return 'User(uid: $uid, email: $email, name: $name, role: ${role.value}, status: ${status.value})';
  }
}
