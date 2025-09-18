# Role Colors Utility

Utility class untuk mengelola warna berdasarkan role user secara konsisten di seluruh aplikasi.

## Import

```dart
import '../utils/role_colors.dart';
```

## Penggunaan Dasar

### Get Role Color

```dart
// Mendapatkan warna role utama
Color roleColor = RoleColors.getRoleColor(user.role);

// Admin: DSColors.error (red)
// Moderator: DSColors.brandPrimary (blue)
// User: DSColors.success (green)
```

### Get Role Color with Alpha

```dart
// Warna dengan transparansi
Color transparentColor = RoleColors.getRoleColorWithAlpha(user.role, 0.3);
```

### Get Role Color Variants

```dart
// Warna terang
Color lightColor = RoleColors.getRoleColorLight(user.role);

// Warna gelap (untuk dark theme)
Color darkColor = RoleColors.getRoleColorDark(user.role);
```

### Role Helper Methods

```dart
// Nama role sebagai string
String roleName = RoleColors.getRoleName(user.role);

// Check apakah role elevated (admin/moderator)
bool isElevated = RoleColors.isElevatedRole(user.role);
```

## Migration dari Method Lama

### Sebelum:

```dart
Color _getRoleColor(UserRole role) {
  switch (role) {
    case UserRole.admin:
      return DSColors.error;
    case UserRole.moderator:
      return DSColors.brandPrimary;
    case UserRole.user:
      return DSColors.success;
  }
}
```

### Sesudah:

```dart
import '../utils/role_colors.dart';

// Langsung gunakan
Color roleColor = RoleColors.getRoleColor(user.role);
```

## Keuntungan

1. **Konsistensi**: Semua file menggunakan logic yang sama
2. **Maintainability**: Hanya perlu update di satu tempat
3. **Type Safety**: Full type checking untuk UserRole
4. **Feature Rich**: Berbagai variant warna dan helper methods
5. **Design System Compliant**: Menggunakan DSColors

## Files yang Perlu Dimigrasikan

Berikut adalah file-file yang memiliki `_getRoleColor` method dan bisa dimigrasikan:

- ✅ `main_screen.dart` - **COMPLETED**
- `user_list_screen_old.dart`
- `profile_screen_backup.dart`
- `profile/widgets/theme_mode_selector.dart`
- `profile/widgets/profile_header.dart`
- `profile/widgets/profile_actions.dart`
- `profile/widgets/password_change_dialog.dart`
- `profile/widgets/edit_profile_dialog.dart`
- `home_screen.dart`
- `user_list/widgets/user_detail_dialog.dart`
- `user_list/widgets/user_dialogs.dart`
- `user_list/widgets/user_card.dart`

## Next Steps

1. Import `RoleColors` utility ke file yang memerlukan
2. Ganti `_getRoleColor(role)` dengan `RoleColors.getRoleColor(role)`
3. Hapus method `_getRoleColor` lokal
4. Test untuk memastikan warna masih konsisten
