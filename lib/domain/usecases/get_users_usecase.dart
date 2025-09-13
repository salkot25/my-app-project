import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

/// Use case for getting all users (admin and moderator only)
class GetUsersUseCase {
  const GetUsersUseCase({required this.userRepository});

  final UserRepository userRepository;

  /// Execute get all users
  Future<Either<Failure, List<User>>> call({
    required String currentUserUid,
  }) async {
    // Get current user to check permissions
    final currentUserResult = await userRepository.getUserProfile(
      currentUserUid,
    );

    if (currentUserResult.isLeft) {
      return Left(currentUserResult.left);
    }

    final currentUser = currentUserResult.right;

    // Check if current user has permission to view all users
    if (!currentUser.canViewAllUsers) {
      return const Left(RoleFailure.insufficientPermissions());
    }

    // Get all users
    final usersResult = await userRepository.getAllUsers(currentUserUid);

    return usersResult;
  }
}
