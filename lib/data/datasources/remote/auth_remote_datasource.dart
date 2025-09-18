import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/errors/failures.dart';

/// Remote data source for Firebase Authentication
class AuthRemoteDataSource {
  const AuthRemoteDataSource({required this.firebaseAuth});

  final FirebaseAuth firebaseAuth;

  /// Current authenticated Firebase user
  User? get currentFirebaseUser => firebaseAuth.currentUser;

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => firebaseAuth.authStateChanges();

  /// Sign up with email and password
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure.unknown();
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw const AuthFailure.unknown();
    }
  }

  /// Sign in with email and password
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthFailure.unknown();
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw const AuthFailure.unknown();
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw const AuthFailure.unknown();
    }
  }

  /// Delete current user account
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure.userNotFound();
      }
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw const AuthFailure.unknown();
    }
  }

  /// Send email verification
  Future<void> sendEmailVerification() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure.userNotFound();
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw const AuthFailure.unknown();
    }
  }

  /// Check if current user's email is verified
  bool get isEmailVerified => firebaseAuth.currentUser?.emailVerified ?? false;

  /// Get current user's UID
  String? get currentUserUid => firebaseAuth.currentUser?.uid;

  /// Change user password (requires re-authentication)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthFailure.userNotFound();
      }

      // Re-authenticate user with current password first
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _mapFirebaseAuthException(e);
    } catch (e) {
      throw const AuthFailure.unknown();
    }
  }

  /// Map Firebase Auth exceptions to our custom failures
  AuthFailure _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return const AuthFailure.weakPassword();
      case 'email-already-in-use':
        return const AuthFailure.emailAlreadyInUse();
      case 'user-not-found':
        return const AuthFailure.userNotFound();
      case 'wrong-password':
        return const AuthFailure.wrongPassword();
      case 'invalid-email':
        return const AuthFailure.invalidEmail();
      case 'user-disabled':
        return const AuthFailure.userDisabled();
      case 'too-many-requests':
        return const AuthFailure.tooManyRequests();
      case 'operation-not-allowed':
        return const AuthFailure.operationNotAllowed();
      case 'network-request-failed':
        return const AuthFailure.networkError();
      default:
        return AuthFailure(message: e.message);
    }
  }
}
