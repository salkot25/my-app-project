import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/user_role.dart';
import '../../domain/entities/user_status.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

/// Implementation of UserRepository using Firestore
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl({required this.userRemoteDataSource});

  final UserRemoteDataSource userRemoteDataSource;

  @override
  Future<Either<FirestoreFailure, User>> createUserProfile({
    required String uid,
    required String email,
    required String name,
  }) async {
    try {
      final userModel = await userRemoteDataSource.createUserProfile(
        uid: uid,
        email: email,
        name: name,
      );
      return Right(userModel.toEntity());
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> getUserProfile(String uid) async {
    try {
      final userModel = await userRemoteDataSource.getUserProfile(uid);
      return Right(userModel.toEntity());
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> updateUserProfile({
    required String uid,
    required String currentUserUid,
    String? name,
    String? email,
  }) async {
    try {
      // Check if user is updating their own profile
      if (uid != currentUserUid) {
        // Get current user to check if they have admin privileges
        final currentUserModel = await userRemoteDataSource.getUserProfile(
          currentUserUid,
        );
        final currentUser = currentUserModel.toEntity();

        if (!currentUser.isAdmin) {
          return const Left(FirestoreFailure.permissionDenied());
        }
      }

      final userModel = await userRemoteDataSource.updateUserProfile(
        uid: uid,
        name: name,
        email: email,
      );
      return Right(userModel.toEntity());
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> updateUserStatus({
    required String targetUid,
    required String currentUserUid,
    required UserStatus newStatus,
  }) async {
    try {
      // Get current user to check permissions
      final currentUserModel = await userRemoteDataSource.getUserProfile(
        currentUserUid,
      );
      final currentUser = currentUserModel.toEntity();

      // Check if current user can verify users
      if (!currentUser.canVerifyUsers) {
        return const Left(FirestoreFailure.permissionDenied());
      }

      final userModel = await userRemoteDataSource.updateUserStatus(
        targetUid: targetUid,
        newStatus: newStatus,
      );
      return Right(userModel.toEntity());
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, User>> updateUserRole({
    required String targetUid,
    required String currentUserUid,
    required UserRole newRole,
  }) async {
    try {
      // Get current user to check permissions
      final currentUserModel = await userRemoteDataSource.getUserProfile(
        currentUserUid,
      );
      final currentUser = currentUserModel.toEntity();

      // Check if current user can change roles (admin only)
      if (!currentUser.canChangeRoles) {
        return const Left(FirestoreFailure.permissionDenied());
      }

      final userModel = await userRemoteDataSource.updateUserRole(
        targetUid: targetUid,
        newRole: newRole,
      );
      return Right(userModel.toEntity());
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, List<User>>> getAllUsers(
    String currentUserUid,
  ) async {
    try {
      // Get current user to check permissions
      final currentUserModel = await userRemoteDataSource.getUserProfile(
        currentUserUid,
      );
      final currentUser = currentUserModel.toEntity();

      // Check if current user can view all users
      if (!currentUser.canViewAllUsers) {
        return const Left(FirestoreFailure.permissionDenied());
      }

      final userModels = await userRemoteDataSource.getAllUsers();
      final users = userModels.map((model) => model.toEntity()).toList();
      return Right(users);
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Future<Either<FirestoreFailure, void>> deleteUser({
    required String targetUid,
    required String currentUserUid,
  }) async {
    try {
      // Get current user to check permissions
      final currentUserModel = await userRemoteDataSource.getUserProfile(
        currentUserUid,
      );
      final currentUser = currentUserModel.toEntity();

      // Check if current user can delete users (admin only)
      if (!currentUser.canDeleteUsers) {
        return const Left(FirestoreFailure.permissionDenied());
      }

      await userRemoteDataSource.deleteUser(targetUid);
      return const Right(null);
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }

  @override
  Stream<Either<FirestoreFailure, User>> watchUserProfile(String uid) {
    try {
      return userRemoteDataSource
          .watchUserProfile(uid)
          .map<Either<FirestoreFailure, User>>(
            (userModel) => Right(userModel.toEntity()),
          )
          .handleError((error) {
            if (error is FirestoreFailure) {
              return Left(error);
            }
            return const Left(FirestoreFailure.unknown());
          });
    } catch (e) {
      return Stream.value(const Left(FirestoreFailure.unknown()));
    }
  }

  @override
  Future<Either<FirestoreFailure, bool>> userExists(String uid) async {
    try {
      final exists = await userRemoteDataSource.userExists(uid);
      return Right(exists);
    } on FirestoreFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(FirestoreFailure.unknown());
    }
  }
}
