import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/errors/failures.dart';
import '../../../domain/entities/user_role.dart';
import '../../../domain/entities/user_status.dart';
import '../../models/user_model.dart';

/// Remote data source for Firestore user data
class UserRemoteDataSource {
  const UserRemoteDataSource({required this.firestore});

  final FirebaseFirestore firestore;

  static const String _usersCollection = 'users';

  /// Create user profile in Firestore
  Future<UserModel> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      final now = DateTime.now();
      final userModel = UserModel(
        uid: uid,
        email: email,
        name: name,
        role: UserRole.user, // Default role
        status: UserStatus.unverified, // Default status
        createdAt: now,
        updatedAt: now,
      );

      await firestore
          .collection(_usersCollection)
          .doc(uid)
          .set(userModel.toMap());

      return userModel;
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Get user profile by UID
  Future<UserModel> getUserProfile(String uid) async {
    try {
      final doc = await firestore.collection(_usersCollection).doc(uid).get();

      if (!doc.exists) {
        throw const FirestoreFailure.notFound();
      }

      return UserModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Update user profile (non-role, non-status fields only)
  Future<UserModel> updateUserProfile({
    required String uid,
    String? name,
    String? email,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (name != null) updateData['name'] = name;
      if (email != null) updateData['email'] = email;

      await firestore.collection(_usersCollection).doc(uid).update(updateData);

      return getUserProfile(uid);
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Update user status (admin and moderator only)
  Future<UserModel> updateUserStatus({
    required String targetUid,
    required UserStatus newStatus,
  }) async {
    try {
      await firestore.collection(_usersCollection).doc(targetUid).update({
        'status': newStatus.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return getUserProfile(targetUid);
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Update user role (admin only)
  Future<UserModel> updateUserRole({
    required String targetUid,
    required UserRole newRole,
  }) async {
    try {
      await firestore.collection(_usersCollection).doc(targetUid).update({
        'role': newRole.value,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return getUserProfile(targetUid);
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Get all users (admin and moderator only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      final querySnapshot = await firestore
          .collection(_usersCollection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Delete user (admin only)
  Future<void> deleteUser(String uid) async {
    try {
      await firestore.collection(_usersCollection).doc(uid).delete();
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Stream of user profile changes
  Stream<UserModel> watchUserProfile(String uid) {
    try {
      return firestore.collection(_usersCollection).doc(uid).snapshots().map((
        doc,
      ) {
        if (!doc.exists) {
          throw const FirestoreFailure.notFound();
        }
        return UserModel.fromFirestore(doc);
      });
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Check if user exists in Firestore
  Future<bool> userExists(String uid) async {
    try {
      final doc = await firestore.collection(_usersCollection).doc(uid).get();
      return doc.exists;
    } on FirebaseException catch (e) {
      throw _mapFirestoreException(e);
    } catch (e) {
      throw const FirestoreFailure.unknown();
    }
  }

  /// Map Firebase exceptions to our custom failures
  FirestoreFailure _mapFirestoreException(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return const FirestoreFailure.permissionDenied();
      case 'not-found':
        return const FirestoreFailure.notFound();
      case 'already-exists':
        return const FirestoreFailure.alreadyExists();
      case 'unavailable':
        return const FirestoreFailure.unavailable();
      case 'data-loss':
        return const FirestoreFailure.dataLoss();
      default:
        return FirestoreFailure(message: e.message);
    }
  }
}
