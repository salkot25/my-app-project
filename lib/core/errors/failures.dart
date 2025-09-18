import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  const Failure({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Authentication related failures
class AuthFailure extends Failure {
  const AuthFailure({super.message});

  const AuthFailure.weakPassword() : super(message: 'Password is too weak');
  const AuthFailure.emailAlreadyInUse()
    : super(message: 'Email is already in use');
  const AuthFailure.userNotFound()
    : super(message: 'No user found with this email');
  const AuthFailure.wrongPassword() : super(message: 'Wrong password provided');
  const AuthFailure.invalidEmail() : super(message: 'Invalid email address');
  const AuthFailure.userDisabled()
    : super(message: 'This user has been disabled');
  const AuthFailure.tooManyRequests()
    : super(message: 'Too many requests, try again later');
  const AuthFailure.operationNotAllowed()
    : super(message: 'Operation not allowed');
  const AuthFailure.networkError() : super(message: 'Network error occurred');
  const AuthFailure.unknown() : super(message: 'Unknown authentication error');
}

/// Firestore related failures
class FirestoreFailure extends Failure {
  const FirestoreFailure({super.message});

  const FirestoreFailure.permissionDenied()
    : super(message: 'Permission denied');
  const FirestoreFailure.notFound() : super(message: 'Document not found');
  const FirestoreFailure.alreadyExists()
    : super(message: 'Document already exists');
  const FirestoreFailure.unavailable()
    : super(message: 'Firestore service unavailable');
  const FirestoreFailure.dataLoss() : super(message: 'Data loss occurred');
  const FirestoreFailure.unknown() : super(message: 'Unknown Firestore error');
}

/// User role validation failures
class RoleFailure extends Failure {
  const RoleFailure({super.message});

  const RoleFailure.insufficientPermissions()
    : super(message: 'Insufficient permissions for this operation');
  const RoleFailure.invalidRole() : super(message: 'Invalid role specified');
  const RoleFailure.unauthorized() : super(message: 'Unauthorized access');
}

/// User status validation failures
class StatusFailure extends Failure {
  const StatusFailure({super.message});

  const StatusFailure.unverifiedUser()
    : super(message: 'User account is not verified');
  const StatusFailure.suspendedUser()
    : super(message: 'User account is suspended');
  const StatusFailure.invalidStatus()
    : super(message: 'Invalid status specified');
}
