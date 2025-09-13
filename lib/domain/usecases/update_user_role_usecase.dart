import 'package:either_dart/either.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';
import '../../core/errors/failures.dart';

class UpdateUserRoleUseCase {
  final UserRepository userRepository;

  UpdateUserRoleUseCase({required this.userRepository});

  Future<Either<Failure, User>> call({
    required String targetUid,
    required String currentUserUid,
    required UserRole newRole,
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

      // Only admins can change roles
      if (currentUser.role != UserRole.admin) {
        return const Left(RoleFailure.insufficientPermissions());
      }

      // Cannot change your own role
      if (currentUserUid == targetUid) {
        return const Left(RoleFailure(message: 'Cannot change your own role'));
      }

      // Update user role
      final updateResult = await userRepository.updateUserRole(
        targetUid: targetUid,
        currentUserUid: currentUserUid,
        newRole: newRole,
      );

      return updateResult;
    } catch (e) {
      return Left(
        FirestoreFailure(
          message: 'Failed to update user role: ${e.toString()}',
        ),
      );
    }
  }
}
