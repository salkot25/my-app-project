import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../entities/user_role.dart';
import '../entities/user_status.dart';

/// User repository interface for managing user data
abstract class UserRepository {
  /// Create user profile in Firestore after successful registration
  Future<Either<FirestoreFailure, User>> createUserProfile({
    required String uid,
    required String email,
    required String name,
  });

  /// Get user profile by UID
  Future<Either<FirestoreFailure, User>> getUserProfile(String uid);

  /// Update user profile (users can only update their own non-role, non-status fields)
  Future<Either<FirestoreFailure, User>> updateUserProfile({
    required String uid,
    required String currentUserUid,
    String? name,
    String? email,
  });

  /// Update user status (only admin and moderator can verify users)
  Future<Either<FirestoreFailure, User>> updateUserStatus({
    required String targetUid,
    required String currentUserUid,
    required UserStatus newStatus,
  });

  /// Update user role (only admin can change roles)
  Future<Either<FirestoreFailure, User>> updateUserRole({
    required String targetUid,
    required String currentUserUid,
    required UserRole newRole,
  });

  /// Get all users (admin and moderator only)
  Future<Either<FirestoreFailure, List<User>>> getAllUsers(
    String currentUserUid,
  );

  /// Delete user (admin only)
  Future<Either<FirestoreFailure, void>> deleteUser({
    required String targetUid,
    required String currentUserUid,
  });

  /// Stream of user profile changes
  Stream<Either<FirestoreFailure, User>> watchUserProfile(String uid);

  /// Check if user exists in Firestore
  Future<Either<FirestoreFailure, bool>> userExists(String uid);
}
