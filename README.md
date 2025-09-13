# Flutter Authentication & User Management System

A complete Flutter application implementing authentication, user management, and role-based access control using Firebase Authentication, Firestore, and Flutter Riverpod for state management. Built with Clean Architecture principles.

## Features

### 🔐 Authentication & User Management

- **User Registration**: Email/password signup with automatic profile creation
- **User Login**: Secure email/password authentication
- **User Profile Management**: Users can update their own profile information
- **Email Verification**: Automatic email verification sending on registration

### 👥 Role-Based Access Control (RBAC)

- **Three User Roles**:
  - `user`: Default role with basic access
  - `moderator`: Can verify users and view user lists
  - `admin`: Full permissions - can verify, change roles, delete users

### ✅ User Status Management

- **User Status Types**:
  - `unverified`: Default status for new users (limited access)
  - `verified`: Full app access granted
  - `suspended`: Account suspended

### 🛡️ Permission System

- **Role-based permissions**:
  - **View all users**: Admin & Moderator only
  - **Verify users**: Admin & Moderator only
  - **Change user roles**: Admin only
  - **Delete users**: Admin only
- **Smart UI components**: `RoleGate`, `StatusGate`, `VerifiedGate`, `AdminGate`

### 🏗️ Architecture

- **Clean Architecture**: Separation of presentation, domain, and data layers
- **SOLID Principles**: Single responsibility per class
- **Dependency Injection**: Using Flutter Riverpod
- **Error Handling**: Typed failures with proper error propagation
- **Unit Testing**: Comprehensive test coverage for use cases and providers

## Project Structure

```
lib/
├── main.dart                           # App entry point
├── app.dart                           # App configuration & routing
├── core/
│   └── errors/
│       └── failures.dart              # Custom error types & enums
├── presentation/
│   ├── providers/
│   │   ├── auth_provider.dart         # Authentication state management
│   │   └── user_list_provider.dart    # User list state management
│   ├── screens/
│   │   ├── login_screen.dart          # Login UI
│   │   ├── register_screen.dart       # Registration UI
│   │   ├── user_list_screen.dart      # Admin/Moderator user management
│   │   └── profile_screen.dart        # User profile management
│   └── widgets/
│       ├── role_gate.dart             # Role-based access control widgets
│       └── status_gate.dart           # Status-based access control widgets
├── domain/
│   ├── entities/
│   │   └── user.dart                  # User domain entity
│   ├── repositories/
│   │   ├── auth_repository.dart       # Auth repository interface
│   │   └── user_repository.dart       # User repository interface
│   └── usecases/
│       ├── login_usecase.dart         # Login business logic
│       ├── register_usecase.dart      # Registration business logic
│       ├── verify_user_usecase.dart   # User verification business logic
│       └── get_users_usecase.dart     # Get users business logic
└── data/
    ├── datasources/
    │   └── remote/
    │       ├── auth_remote_datasource.dart    # Firebase Auth integration
    │       └── user_remote_datasource.dart    # Firestore integration
    ├── models/
    │   └── user_model.dart            # User data model for Firestore
    └── repositories/
        ├── auth_repository_impl.dart  # Auth repository implementation
        └── user_repository_impl.dart  # User repository implementation
```

## Firebase Setup Status

✅ **COMPLETED SETUP**:

- Firebase project created: `app-project-25`
- FlutterFire configured for all platforms (Android, iOS, Web, Windows)
- Dependencies updated to latest compatible versions (Riverpod 3.0, Firebase 6.x)
- Code updated to Riverpod 3.0 syntax
- **Authentication working**: User login successful ✅

**REQUIRED - Complete These Steps Now**:

1. **Enable Authentication** in [Firebase Console](https://console.firebase.google.com/project/app-project-25/authentication/providers)
2. **Create Firestore database** in [Firestore Console](https://console.firebase.google.com/project/app-project-25/firestore)
3. **Configure security rules** (copy rules below)

---

## Complete Firebase Setup Instructions

### 1. Create Firebase Project

✅ **COMPLETED** - Project ID: `app-project-25`

### 2. Enable Authentication (REQUIRED)

1. Go to [Firebase Console](https://console.firebase.google.com/project/app-project-25/authentication/providers)
2. Click **Get started** in Authentication
3. Go to **Sign-in method** tab
4. Enable **Email/Password** authentication
5. Optionally configure email templates for verification

### 3. Create Firestore Database (REQUIRED)

1. Go to [Firestore Database](https://console.firebase.google.com/project/app-project-25/firestore)
2. Click **Create database**
3. Choose **Start in production mode**
4. Select your preferred region
5. Click **Done**

### 4. Configure Security Rules (REQUIRED)

1. In Firestore, go to **Rules** tab
2. Replace the default rules with the rules below:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own profile
      allow read: if request.auth != null && request.auth.uid == userId;

      // Users can update their own profile (but not role or status)
      allow update: if request.auth != null
        && request.auth.uid == userId
        && !('role' in request.resource.data.diff(resource.data).affectedKeys())
        && !('status' in request.resource.data.diff(resource.data).affectedKeys());

      // Admins and moderators can read all user profiles
      allow read: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'moderator']
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified';

      // Admins and moderators can update user status
      allow update: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'moderator']
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified'
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'updatedAt']);

      // Only admins can update user roles
      allow update: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified'
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['role', 'updatedAt']);

      // Only admins can delete users
      allow delete: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified';

      // Allow creation of new user profiles (during registration)
      allow create: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.role == 'user'
        && request.resource.data.status == 'unverified';
    }
  }
}
```

3. Click **Publish**

### 5. Test the Application

After completing steps 2-4 above, you can run:

```bash
flutter run -d chrome
```

---

## Original Firebase Setup Instructions (Reference)

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project
3. Enable Google Analytics (optional)

### 2. Configure Authentication

1. Go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** authentication
3. Optionally configure email templates for verification

### 3. Setup Firestore Database

1. Go to **Firestore Database**
2. Create database in **production mode**
3. Choose your region

### 4. Add Flutter App

1. Click **Add app** > **Flutter**
2. Follow the setup instructions to download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
3. Install Firebase CLI and FlutterFire CLI:
   ```bash
   npm install -g firebase-tools
   dart pub global activate flutterfire_cli
   ```
4. Configure Firebase for your app:
   ```bash
   flutterfire configure
   ```
   **✅ COMPLETED**: This project has been configured with Firebase project `app-project-25`

### 5. Required Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own profile
      allow read: if request.auth != null && request.auth.uid == userId;

      // Users can update their own profile (but not role or status)
      allow update: if request.auth != null
        && request.auth.uid == userId
        && !('role' in request.resource.data.diff(resource.data).affectedKeys())
        && !('status' in request.resource.data.diff(resource.data).affectedKeys());

      // Admins and moderators can read all user profiles
      allow read: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'moderator']
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified';

      // Admins and moderators can update user status
      allow update: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['admin', 'moderator']
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified'
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['status', 'updatedAt']);

      // Only admins can update user roles
      allow update: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified'
        && request.resource.data.diff(resource.data).affectedKeys().hasOnly(['role', 'updatedAt']);

      // Only admins can delete users
      allow delete: if request.auth != null
        && exists(/databases/$(database)/documents/users/$(request.auth.uid))
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin'
        && get(/databases/$(database)/documents/users/$(request.auth.uid)).data.status == 'verified';

      // Allow creation of new user profiles (during registration)
      allow create: if request.auth != null
        && request.auth.uid == userId
        && request.resource.data.role == 'user'
        && request.resource.data.status == 'unverified';
    }
  }
}
```

## Firestore Schema

### Users Collection (`users/{uid}`)

```json
{
  "email": "user@example.com",
  "name": "John Doe",
  "role": "user", // "user" | "moderator" | "admin"
  "status": "unverified", // "unverified" | "verified" | "suspended"
  "createdAt": "2023-01-01T00:00:00.000Z",
  "updatedAt": "2023-01-01T00:00:00.000Z"
}
```

### Field Descriptions

- **email**: User's email address (from Firebase Auth)
- **name**: User's display name
- **role**: User's permission level
- **status**: User's verification status
- **createdAt**: Account creation timestamp
- **updatedAt**: Last modification timestamp

## Installation & Setup

### 1. Clone the Repository

```bash
git clone <repository-url>
cd my_project
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure Firebase

Follow the Firebase setup instructions above.

### 4. Run the App

```bash
flutter run
```

## Usage Flow

### 1. User Registration Flow

1. User registers with email/password
2. Firebase Authentication account created
3. User profile created in Firestore with:
   - `role: "user"`
   - `status: "unverified"`
4. Email verification sent
5. User redirected to profile screen showing unverified status

### 2. Admin Verification Flow

1. Admin logs in and navigates to User List
2. Admin can see all registered users
3. Admin clicks "Update Status" for unverified user
4. Admin selects "Verify" to change status to `verified`
5. User can now access full application

### 3. Permission Examples

- **Regular User**: Can only view/edit own profile
- **Moderator**: Can view all users, verify users
- **Admin**: Full access - can change roles, delete users

## Testing

### Run Unit Tests

```bash
flutter test
```

### Test Coverage Includes

- **Domain Use Cases**: Registration, verification, user management
- **Providers**: Authentication state management
- **Error Handling**: Custom failures and edge cases

### Test Files

- `test/domain/register_usecase_test.dart` - Registration business logic
- `test/domain/verify_user_usecase_test.dart` - User verification logic
- `test/presentation/auth_provider_test.dart` - Authentication state management

## Dependencies

### Production Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.9 # State management
  firebase_core: ^2.24.2 # Firebase core
  firebase_auth: ^4.15.3 # Authentication
  cloud_firestore: ^4.13.6 # Database
  go_router: ^12.1.3 # Navigation
  equatable: ^2.0.5 # Value equality
  either_dart: ^1.0.0 # Error handling
```

### Development Dependencies

```yaml
dev_dependencies:
  flutter_test: ^3.0.0 # Testing framework
  mocktail: ^1.0.2 # Mocking
  fake_cloud_firestore: ^2.4.2 # Firestore testing
```

## Key Features Implementation

### Role-Based Access Control

```dart
// Usage example
RoleGate(
  allowedRoles: [UserRole.admin, UserRole.moderator],
  child: UserManagementWidget(),
  fallback: AccessDeniedWidget(),
)
```

### Status-Based Access Control

```dart
// Usage example
VerifiedGate(
  child: MainAppContent(),
  fallback: PendingVerificationWidget(),
)
```

### Clean Architecture Benefits

- **Testability**: Easy to unit test business logic
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features
- **Flexibility**: Easy to swap implementations

## Error Handling

The app implements comprehensive error handling with typed failures:

- **AuthFailure**: Authentication-related errors
- **FirestoreFailure**: Database operation errors
- **RoleFailure**: Permission-related errors
- **StatusFailure**: User status validation errors

## Security Considerations

- **Firebase Security Rules**: Comprehensive rules preventing unauthorized access
- **Role Validation**: Server-side validation of all role-based operations
- **Status Checks**: User status validated before granting access
- **Input Validation**: All user inputs validated client and server-side

## Contributing

1. Follow the existing architecture patterns
2. Add unit tests for new features
3. Update this README for significant changes
4. Follow Dart/Flutter coding conventions

## License

This project is licensed under the MIT License - see the LICENSE file for details.
