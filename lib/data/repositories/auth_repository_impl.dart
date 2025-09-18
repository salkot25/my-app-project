import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:either_dart/either.dart';
import '../../core/errors/failures.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';

/// Implementation of AuthRepository using Firebase Authentication
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.authRemoteDataSource});

  final AuthRemoteDataSource authRemoteDataSource;

  @override
  firebase_auth.User? get currentFirebaseUser =>
      authRemoteDataSource.currentFirebaseUser;

  @override
  Stream<firebase_auth.User?> get authStateChanges =>
      authRemoteDataSource.authStateChanges;

  @override
  Future<Either<AuthFailure, firebase_auth.User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(AuthFailure.unknown());
    }
  }

  @override
  Future<Either<AuthFailure, firebase_auth.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final user = await authRemoteDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(AuthFailure.unknown());
    }
  }

  @override
  Future<Either<AuthFailure, void>> signOut() async {
    try {
      await authRemoteDataSource.signOut();
      return const Right(null);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(AuthFailure.unknown());
    }
  }

  @override
  Future<Either<AuthFailure, void>> deleteAccount() async {
    try {
      await authRemoteDataSource.deleteAccount();
      return const Right(null);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(AuthFailure.unknown());
    }
  }

  @override
  Future<Either<AuthFailure, void>> sendEmailVerification() async {
    try {
      await authRemoteDataSource.sendEmailVerification();
      return const Right(null);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(AuthFailure.unknown());
    }
  }

  @override
  bool get isEmailVerified => authRemoteDataSource.isEmailVerified;

  @override
  String? get currentUserUid => authRemoteDataSource.currentUserUid;

  @override
  Future<Either<AuthFailure, void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await authRemoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on AuthFailure catch (failure) {
      return Left(failure);
    } catch (e) {
      return const Left(AuthFailure.unknown());
    }
  }
}
