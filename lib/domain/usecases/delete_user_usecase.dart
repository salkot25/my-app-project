import 'package:either_dart/either.dart';
import '../entities/user_role.dart';
import '../repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class DeleteUserUseCase {
  final UserRepository userRepository;

  DeleteUserUseCase({required this.userRepository});

  Future<Either<Failure, void>> call({
    required String currentUserUid,
    required String targetUid,
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

      // Only admins can delete users
      if (currentUser.role != UserRole.admin) {
        return const Left(RoleFailure.insufficientPermissions());
      }

      // Cannot delete yourself
      if (currentUserUid == targetUid) {
        return const Left(
          RoleFailure(message: 'Cannot delete your own account'),
        );
      }

      // Get target user to verify it exists
      final targetUserResult = await userRepository.getUserProfile(targetUid);
      if (targetUserResult.isLeft) {
        return Left(targetUserResult.left);
      }

      // Delete user profile from Firestore
      final deleteProfileResult = await userRepository.deleteUser(
        targetUid: targetUid,
        currentUserUid: currentUserUid,
      );

      if (deleteProfileResult.isLeft) {
        return Left(deleteProfileResult.left);
      }

      // Note: We don't delete from Firebase Auth as it requires admin SDK
      // In a real implementation, this would be done via Cloud Functions
      // For now, we just delete the Firestore profile

      return const Right(null);
    } catch (e) {
      return Left(
        FirestoreFailure(message: 'Failed to delete user: ${e.toString()}'),
      );
    }
  }
}
