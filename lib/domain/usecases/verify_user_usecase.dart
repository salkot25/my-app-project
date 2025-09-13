import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for verifying a user (admin and moderator only)
class VerifyUserUseCase {
  const VerifyUserUseCase({required this.userRepository});

  final UserRepository userRepository;

  /// Execute user verification
  Future<Either<Failure, User>> call({
    required String targetUid,
    required String currentUserUid,
    required UserStatus newStatus,
  }) async {
    // Get current user to check permissions
    final currentUserResult = await userRepository.getUserProfile(
      currentUserUid,
    );

    if (currentUserResult.isLeft) {
      return Left(currentUserResult.left);
    }

    final currentUser = currentUserResult.right;

    // Check if current user has permission to verify users
    if (!currentUser.canVerifyUsers) {
      return const Left(RoleFailure.insufficientPermissions());
    }

    // Update target user's status
    final updateResult = await userRepository.updateUserStatus(
      targetUid: targetUid,
      currentUserUid: currentUserUid,
      newStatus: newStatus,
    );

    return updateResult;
  }
}
