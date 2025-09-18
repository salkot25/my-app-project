import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:either_dart/either.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:my_project/core/errors/failures.dart';
import 'package:my_project/domain/entities/user.dart';
import 'package:my_project/domain/entities/user_role.dart';
import 'package:my_project/domain/entities/user_status.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/domain/usecases/register_usecase.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  late RegisterUseCase usecase;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    usecase = RegisterUseCase(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
    );
  });

  group('RegisterUseCase', () {
    const String testEmail = 'test@example.com';
    const String testPassword = 'password123';
    const String testName = 'Test User';
    const String testUid = 'test-uid-123';

    final mockFirebaseUser = MockFirebaseUser();
    final mockUser = User(
      uid: testUid,
      email: testEmail,
      name: testName,
      role: UserRole.user,
      status: UserStatus.unverified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should register user successfully', () async {
      // Arrange
      when(() => mockFirebaseUser.uid).thenReturn(testUid);
      when(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(mockFirebaseUser));

      when(
        () => mockUserRepository.createUserProfile(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Right(mockUser));

      when(
        () => mockAuthRepository.sendEmailVerification(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        name: testName,
      );

      // Assert
      expect(result.isRight, true);
      expect(result.right, mockUser);

      verify(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);

      verify(
        () => mockUserRepository.createUserProfile(
          uid: testUid,
          email: testEmail,
          name: testName,
        ),
      ).called(1);

      verify(() => mockAuthRepository.sendEmailVerification()).called(1);
    });

    test('should return AuthFailure when sign up fails', () async {
      // Arrange
      const authFailure = AuthFailure.emailAlreadyInUse();
      when(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(authFailure));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        name: testName,
      );

      // Assert
      expect(result.isLeft, true);
      expect(result.left, authFailure);

      verify(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        ),
      ).called(1);

      verifyNever(
        () => mockUserRepository.createUserProfile(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          name: any(named: 'name'),
        ),
      );

      verifyNever(() => mockAuthRepository.sendEmailVerification());
    });

    test(
      'should clean up Firebase user and return FirestoreFailure when user profile creation fails',
      () async {
        // Arrange
        const firestoreFailure = FirestoreFailure.permissionDenied();
        when(() => mockFirebaseUser.uid).thenReturn(testUid);
        when(
          () => mockAuthRepository.signUpWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => Right(mockFirebaseUser));

        when(
          () => mockUserRepository.createUserProfile(
            uid: any(named: 'uid'),
            email: any(named: 'email'),
            name: any(named: 'name'),
          ),
        ).thenAnswer((_) async => const Left(firestoreFailure));

        when(
          () => mockAuthRepository.deleteAccount(),
        ).thenAnswer((_) async => const Right(null));

        // Act
        final result = await usecase(
          email: testEmail,
          password: testPassword,
          name: testName,
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left, firestoreFailure);

        verify(
          () => mockAuthRepository.signUpWithEmailAndPassword(
            email: testEmail,
            password: testPassword,
          ),
        ).called(1);

        verify(
          () => mockUserRepository.createUserProfile(
            uid: testUid,
            email: testEmail,
            name: testName,
          ),
        ).called(1);

        verify(() => mockAuthRepository.deleteAccount()).called(1);
        verifyNever(() => mockAuthRepository.sendEmailVerification());
      },
    );

    test('should create user with default role and status', () async {
      // Arrange
      when(() => mockFirebaseUser.uid).thenReturn(testUid);
      when(
        () => mockAuthRepository.signUpWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(mockFirebaseUser));

      when(
        () => mockUserRepository.createUserProfile(
          uid: any(named: 'uid'),
          email: any(named: 'email'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Right(mockUser));

      when(
        () => mockAuthRepository.sendEmailVerification(),
      ).thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase(
        email: testEmail,
        password: testPassword,
        name: testName,
      );

      // Assert
      expect(result.isRight, true);
      final user = result.right;
      expect(user.role, UserRole.user);
      expect(user.status, UserStatus.unverified);
    });
  });
}
