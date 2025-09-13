import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/user_repository.dart';

/// Use case for user registration
class RegisterUseCase {
  const RegisterUseCase({
    required this.authRepository,
    required this.userRepository,
  });

  final AuthRepository authRepository;
  final UserRepository userRepository;

  /// Execute registration flow
  Future<Either<Failure, User>> call({
    required String email,
    required String password,
    required String name,
  }) async {
    // Check if user already exists in Firestore (edge case handling)
    // This is optional since Firebase Auth will handle duplicate emails

    // Sign up with Firebase Auth
    final authResult = await authRepository.signUpWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (authResult.isLeft) {
      return Left(authResult.left);
    }

    final firebaseUser = authResult.right;

    // Create user profile in Firestore with default role=user, status=unverified
    final userProfileResult = await userRepository.createUserProfile(
      uid: firebaseUser.uid,
      email: email,
      name: name,
    );

    if (userProfileResult.isLeft) {
      // If Firestore creation fails, we should clean up the Firebase Auth user
      await authRepository.deleteAccount();
      return Left(userProfileResult.left);
    }

    // Send email verification
    await authRepository.sendEmailVerification();

    return Right(userProfileResult.right);
  }
}
