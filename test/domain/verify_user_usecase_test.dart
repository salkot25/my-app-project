import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:either_dart/either.dart';
import 'package:my_project/core/errors/failures.dart';
import 'package:my_project/domain/entities/user.dart';
import 'package:my_project/domain/repositories/user_repository.dart';
import 'package:my_project/domain/usecases/verify_user_usecase.dart';

// Mock classes
class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late VerifyUserUseCase usecase;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    usecase = VerifyUserUseCase(userRepository: mockUserRepository);
  });

  group('VerifyUserUseCase', () {
    const String currentUserUid = 'admin-uid-123';
    const String targetUserUid = 'target-uid-456';
    const UserStatus newStatus = UserStatus.verified;

    final adminUser = User(
      uid: currentUserUid,
      email: 'admin@example.com',
      name: 'Admin User',
      role: UserRole.admin,
      status: UserStatus.verified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final moderatorUser = adminUser.copyWith(role: UserRole.moderator);

    final regularUser = adminUser.copyWith(role: UserRole.user);

    final targetUser = User(
      uid: targetUserUid,
      email: 'target@example.com',
      name: 'Target User',
      role: UserRole.user,
      status: UserStatus.unverified,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final verifiedTargetUser = targetUser.copyWith(
      status: UserStatus.verified,
      updatedAt: DateTime.now(),
    );

    test(
      'should verify user successfully when current user is admin',
      () async {
        // Arrange
        when(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).thenAnswer((_) async => Right(adminUser));

        when(
          () => mockUserRepository.updateUserStatus(
            targetUid: any(named: 'targetUid'),
            currentUserUid: any(named: 'currentUserUid'),
            newStatus: any(named: 'newStatus'),
          ),
        ).thenAnswer((_) async => Right(verifiedTargetUser));

        // Act
        final result = await usecase(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        );

        // Assert
        expect(result.isRight, true);
        expect(result.right, verifiedTargetUser);

        verify(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).called(1);
        verify(
          () => mockUserRepository.updateUserStatus(
            targetUid: targetUserUid,
            currentUserUid: currentUserUid,
            newStatus: newStatus,
          ),
        ).called(1);
      },
    );

    test(
      'should verify user successfully when current user is moderator',
      () async {
        // Arrange
        when(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).thenAnswer((_) async => Right(moderatorUser));

        when(
          () => mockUserRepository.updateUserStatus(
            targetUid: any(named: 'targetUid'),
            currentUserUid: any(named: 'currentUserUid'),
            newStatus: any(named: 'newStatus'),
          ),
        ).thenAnswer((_) async => Right(verifiedTargetUser));

        // Act
        final result = await usecase(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        );

        // Assert
        expect(result.isRight, true);
        expect(result.right, verifiedTargetUser);

        verify(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).called(1);
        verify(
          () => mockUserRepository.updateUserStatus(
            targetUid: targetUserUid,
            currentUserUid: currentUserUid,
            newStatus: newStatus,
          ),
        ).called(1);
      },
    );

    test(
      'should return RoleFailure when current user is not admin or moderator',
      () async {
        // Arrange
        when(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).thenAnswer((_) async => Right(regularUser));

        // Act
        final result = await usecase(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left, isA<RoleFailure>());
        expect(
          result.left.message,
          'Insufficient permissions for this operation',
        );

        verify(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).called(1);
        verifyNever(
          () => mockUserRepository.updateUserStatus(
            targetUid: any(named: 'targetUid'),
            currentUserUid: any(named: 'currentUserUid'),
            newStatus: any(named: 'newStatus'),
          ),
        );
      },
    );

    test(
      'should return FirestoreFailure when getting current user fails',
      () async {
        // Arrange
        const firestoreFailure = FirestoreFailure.notFound();
        when(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).thenAnswer((_) async => const Left(firestoreFailure));

        // Act
        final result = await usecase(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left, firestoreFailure);

        verify(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).called(1);
        verifyNever(
          () => mockUserRepository.updateUserStatus(
            targetUid: any(named: 'targetUid'),
            currentUserUid: any(named: 'currentUserUid'),
            newStatus: any(named: 'newStatus'),
          ),
        );
      },
    );

    test(
      'should return FirestoreFailure when updating user status fails',
      () async {
        // Arrange
        const firestoreFailure = FirestoreFailure.permissionDenied();
        when(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).thenAnswer((_) async => Right(adminUser));

        when(
          () => mockUserRepository.updateUserStatus(
            targetUid: any(named: 'targetUid'),
            currentUserUid: any(named: 'currentUserUid'),
            newStatus: any(named: 'newStatus'),
          ),
        ).thenAnswer((_) async => const Left(firestoreFailure));

        // Act
        final result = await usecase(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        );

        // Assert
        expect(result.isLeft, true);
        expect(result.left, firestoreFailure);

        verify(
          () => mockUserRepository.getUserProfile(currentUserUid),
        ).called(1);
        verify(
          () => mockUserRepository.updateUserStatus(
            targetUid: targetUserUid,
            currentUserUid: currentUserUid,
            newStatus: newStatus,
          ),
        ).called(1);
      },
    );

    test('should work with different status values', () async {
      // Arrange
      when(
        () => mockUserRepository.getUserProfile(currentUserUid),
      ).thenAnswer((_) async => Right(adminUser));

      final suspendedTargetUser = targetUser.copyWith(
        status: UserStatus.suspended,
        updatedAt: DateTime.now(),
      );

      when(
        () => mockUserRepository.updateUserStatus(
          targetUid: any(named: 'targetUid'),
          currentUserUid: any(named: 'currentUserUid'),
          newStatus: any(named: 'newStatus'),
        ),
      ).thenAnswer((_) async => Right(suspendedTargetUser));

      // Act
      final result = await usecase(
        targetUid: targetUserUid,
        currentUserUid: currentUserUid,
        newStatus: UserStatus.suspended,
      );

      // Assert
      expect(result.isRight, true);
      expect(result.right.status, UserStatus.suspended);

      verify(
        () => mockUserRepository.updateUserStatus(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: UserStatus.suspended,
        ),
      ).called(1);
    });

    test('should pass through all parameters correctly', () async {
      // Arrange
      when(
        () => mockUserRepository.getUserProfile(currentUserUid),
      ).thenAnswer((_) async => Right(adminUser));

      when(
        () => mockUserRepository.updateUserStatus(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        ),
      ).thenAnswer((_) async => Right(verifiedTargetUser));

      // Act
      final result = await usecase(
        targetUid: targetUserUid,
        currentUserUid: currentUserUid,
        newStatus: newStatus,
      );

      // Assert
      expect(result.isRight, true);

      verify(
        () => mockUserRepository.updateUserStatus(
          targetUid: targetUserUid,
          currentUserUid: currentUserUid,
          newStatus: newStatus,
        ),
      ).called(1);
    });
  });
}
