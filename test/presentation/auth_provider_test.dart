import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:either_dart/either.dart';
import 'package:my_project/core/errors/failures.dart';
import 'package:my_project/domain/entities/user.dart';
import 'package:my_project/domain/repositories/auth_repository.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/domain/usecases/login_usecase.dart';
import 'package:my_project/domain/usecases/register_usecase.dart';
import 'package:my_project/presentation/providers/auth_provider.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}

class MockUserRepository extends Mock implements UserRepository {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockFirebaseUser extends Mock implements firebase_auth.User {}

void main() {
  late ProviderContainer container;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();

    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
      ],
    );

    // Set up default stream behavior
    when(
      () => mockAuthRepository.authStateChanges,
    ).thenAnswer((_) => Stream.value(null));
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthProvider', () {
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
      status: UserStatus.verified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('initial state should be not authenticated', () {
      final authState = container.read(authProvider);

      expect(authState.isAuthenticated, false);
      expect(authState.firebaseUser, null);
      expect(authState.domainUser, null);
      expect(authState.isLoading, false);
      expect(authState.error, null);
    });

    test('should set loading state during login', () async {
      // Arrange
      when(
        () => mockLoginUseCase.call(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async {
        // Simulate slow operation
        await Future.delayed(const Duration(milliseconds: 100));
        return Right(mockUser);
      });

      final authNotifier = container.read(authProvider.notifier);

      // Act
      final loginFuture = authNotifier.login(
        email: testEmail,
        password: testPassword,
      );

      // Assert loading state
      await Future.delayed(Duration.zero); // Allow state update
      final loadingState = container.read(authProvider);
      expect(loadingState.isLoading, true);
      expect(loadingState.error, null);

      await loginFuture;
    });

    test('should handle successful login', () async {
      // Arrange
      when(
        () => mockLoginUseCase.call(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Right(mockUser));

      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.login(email: testEmail, password: testPassword);

      // Assert
      verify(
        () => mockLoginUseCase.call(email: testEmail, password: testPassword),
      ).called(1);

      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.error, null);
    });

    test('should handle failed login', () async {
      // Arrange
      const authFailure = AuthFailure.wrongPassword();
      when(
        () => mockLoginUseCase.call(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => const Left(authFailure));

      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.login(email: testEmail, password: testPassword);

      // Assert
      verify(
        () => mockLoginUseCase.call(email: testEmail, password: testPassword),
      ).called(1);

      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.error, authFailure.message);
      expect(finalState.isAuthenticated, false);
    });

    test('should handle successful registration', () async {
      // Arrange
      when(
        () => mockRegisterUseCase.call(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Right(mockUser));

      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.register(
        email: testEmail,
        password: testPassword,
        name: testName,
      );

      // Assert
      verify(
        () => mockRegisterUseCase.call(
          email: testEmail,
          password: testPassword,
          name: testName,
        ),
      ).called(1);

      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.error, null);
    });

    test('should handle failed registration', () async {
      // Arrange
      const authFailure = AuthFailure.emailAlreadyInUse();
      when(
        () => mockRegisterUseCase.call(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => const Left(authFailure));

      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.register(
        email: testEmail,
        password: testPassword,
        name: testName,
      );

      // Assert
      verify(
        () => mockRegisterUseCase.call(
          email: testEmail,
          password: testPassword,
          name: testName,
        ),
      ).called(1);

      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.error, authFailure.message);
      expect(finalState.isAuthenticated, false);
    });

    test('should handle logout', () async {
      // Arrange
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Right(null));

      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.logout();

      // Assert
      verify(() => mockAuthRepository.signOut()).called(1);

      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.error, null);
    });

    test('should handle failed logout', () async {
      // Arrange
      const authFailure = AuthFailure.networkError();
      when(
        () => mockAuthRepository.signOut(),
      ).thenAnswer((_) async => const Left(authFailure));

      final authNotifier = container.read(authProvider.notifier);

      // Act
      await authNotifier.logout();

      // Assert
      verify(() => mockAuthRepository.signOut()).called(1);

      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.error, authFailure.message);
    });

    test('should update state when Firebase user signs in', () async {
      // Arrange
      when(() => mockFirebaseUser.uid).thenReturn(testUid);
      when(
        () => mockUserRepository.getUserProfile(testUid),
      ).thenAnswer((_) async => Right(mockUser));

      // Set up auth state changes stream to emit the user
      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockFirebaseUser));

      // Create a new container to trigger the auth state listener
      final newContainer = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
          registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        ],
      );

      // Act
      await Future.delayed(
        const Duration(milliseconds: 50),
      ); // Allow stream processing

      // Assert
      final authState = newContainer.read(authProvider);
      expect(authState.firebaseUser, mockFirebaseUser);
      expect(authState.domainUser, mockUser);
      expect(authState.isAuthenticated, true);

      newContainer.dispose();
    });

    test('should handle Firebase user sign out', () async {
      // Arrange
      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream.value(null));

      // Create a new container to trigger the auth state listener
      final newContainer = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
          registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        ],
      );

      // Act
      await Future.delayed(
        const Duration(milliseconds: 50),
      ); // Allow stream processing

      // Assert
      final authState = newContainer.read(authProvider);
      expect(authState.firebaseUser, null);
      expect(authState.domainUser, null);
      expect(authState.isAuthenticated, false);

      newContainer.dispose();
    });

    test('should handle Firestore error when getting user profile', () async {
      // Arrange
      when(() => mockFirebaseUser.uid).thenReturn(testUid);
      when(
        () => mockUserRepository.getUserProfile(testUid),
      ).thenAnswer((_) async => const Left(FirestoreFailure.notFound()));

      // Set up auth state changes stream to emit the user
      when(
        () => mockAuthRepository.authStateChanges,
      ).thenAnswer((_) => Stream.value(mockFirebaseUser));

      // Create a new container to trigger the auth state listener
      final newContainer = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
          registerUseCaseProvider.overrideWithValue(mockRegisterUseCase),
        ],
      );

      // Act
      await Future.delayed(
        const Duration(milliseconds: 50),
      ); // Allow stream processing

      // Assert
      final authState = newContainer.read(authProvider);
      expect(authState.firebaseUser, mockFirebaseUser);
      expect(authState.domainUser, null);
      expect(authState.error, isNotNull);
      expect(authState.isLoading, false);

      newContainer.dispose();
    });
  });
}
