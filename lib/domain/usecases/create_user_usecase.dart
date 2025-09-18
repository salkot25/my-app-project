import 'package:either_dart/either.dart';
import '../entities/user.dart';
import '../entities/user_role.dart';
import '../entities/user_status.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class CreateUserUseCase {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  CreateUserUseCase({
    required this.authRepository,
    required this.userRepository,
  });

  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String name,
    required String currentUserUid,
    UserRole role = UserRole.user,
    UserStatus status = UserStatus.unverified,
  }) async {
    try {
      // Get current user to verify permissions
      final currentUserResult = await userRepository.getUserProfile(
        currentUserUid,
      );
      if (currentUserResult.isLeft) {
        return Left(currentUserResult.left);
      }

      final currentUser = currentUserResult.right;

      // Only admins can create users with specific roles/status
      if (currentUser.role != UserRole.admin) {
        return const Left(RoleFailure.insufficientPermissions());
      }

      // Note: Creating users via Firebase Auth requires admin SDK
      // In a real implementation, this would be done via Cloud Functions
      // For now, we'll show that this feature requires backend implementation

      return const Left(
        FirestoreFailure(
          message:
              'User creation requires backend implementation with Firebase Admin SDK. '
              'Please use Firebase Console or implement Cloud Functions for user creation.',
        ),
      );

      // TODO: This would be the actual implementation with Cloud Functions:
      // 1. Call Cloud Function to create Firebase Auth account
      // 2. Create Firestore profile with the specified role and status
      //
      // final createAuthResult = await authRepository.createUserWithEmailAndPassword(
      //   email: email,
      //   password: password,
      // );
      //
      // if (createAuthResult.isLeft) {
      //   return Left(createAuthResult.left);
      // }
      //
      // final firebaseUser = createAuthResult.right;
      //
      // final createProfileResult = await userRepository.createUserProfile(
      //   uid: firebaseUser.uid,
      //   email: email,
      //   name: name,
      // );
      //
      // if (createProfileResult.isLeft) {
      //   // If profile creation fails, we should delete the auth account
      //   // This would also require admin SDK
      //   return Left(createProfileResult.left);
      // }
      //
      // // Update role and status if different from defaults
      // User user = createProfileResult.right;
      //
      // if (role != UserRole.user) {
      //   final updateRoleResult = await userRepository.updateUserRole(
      //     targetUid: user.uid,
      //     currentUserUid: currentUserUid,
      //     newRole: role,
      //   );
      //   if (updateRoleResult.isLeft) {
      //     return Left(updateRoleResult.left);
      //   }
      //   user = updateRoleResult.right;
      // }
      //
      // if (status != UserStatus.unverified) {
      //   final updateStatusResult = await userRepository.updateUserStatus(
      //     targetUid: user.uid,
      //     currentUserUid: currentUserUid,
      //     newStatus: status,
      //   );
      //   if (updateStatusResult.isLeft) {
      //     return Left(updateStatusResult.left);
      //   }
      //   user = updateStatusResult.right;
      // }
      //
      // return Right(user);
    } catch (e) {
      return Left(
        FirestoreFailure(message: 'Failed to create user: ${e.toString()}'),
      );
    }
  }
}
