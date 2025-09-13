import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';

/// Authentication repository interface
abstract class AuthRepository {
  /// Current authenticated Firebase user
  firebase_auth.User? get currentFirebaseUser;

  /// Stream of authentication state changes
  Stream<firebase_auth.User?> get authStateChanges;

  /// Sign up with email and password
  Future<Either<AuthFailure, firebase_auth.User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign in with email and password
  Future<Either<AuthFailure, firebase_auth.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<Either<AuthFailure, void>> signOut();

  /// Delete current user account
  Future<Either<AuthFailure, void>> deleteAccount();

  /// Send email verification
  Future<Either<AuthFailure, void>> sendEmailVerification();

  /// Check if current user's email is verified
  bool get isEmailVerified;

  /// Get current user's UID
  String? get currentUserUid;
}
