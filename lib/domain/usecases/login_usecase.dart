import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

/// Use case for user login
class LoginUseCase {
  const LoginUseCase({
    required this.authRepository,
    required this.userRepository,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;

  /// Execute login flow
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
  }) async {
    // Sign in with Firebase Auth
    final authResult = await authRepository.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (authResult.isLeft) {
      return Left(authResult.left);
    }

    final firebaseUser = authResult.right;

    // Get user profile from Firestore
    final userProfileResult = await userRepository.getUserProfile(
      firebaseUser.uid,
    );

    if (userProfileResult.isLeft) {
      return Left(userProfileResult.left);
    }

    final user = userProfileResult.right;

    // Check if user can access the app
    if (!user.canAccessApp) {
      await authRepository.signOut();
      return const Left(StatusFailure.unverifiedUser());
    }

    return Right(user);
  }
}
