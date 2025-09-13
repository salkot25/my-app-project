import 'package:either_dart/either.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class UpdateUserProfileUseCase {
  final UserRepository userRepository;

  UpdateUserProfileUseCase({required this.userRepository});

  Future<Either<Failure, User>> call({
    required String targetUid,
    required String currentUserUid,
    String? newName,
    String? newEmail,
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

      // Check permissions: admin can edit anyone, users can only edit themselves
      if (!currentUser.isAdmin && currentUserUid != targetUid) {
        return const Left(RoleFailure.insufficientPermissions());
      }

      // Update user profile
      final updateResult = await userRepository.updateUserProfile(
        uid: targetUid,
        currentUserUid: currentUserUid,
        name: newName,
        email: newEmail,
      );

      return updateResult;
    } catch (e) {
      return Left(
        FirestoreFailure(
          message: 'Failed to update user profile: ${e.toString()}',
        ),
      );
    }
  }
}
