# 🔥 Firebase Options Setup Guide

## ⚠️ IMPORTANT: firebase_options.dart is NOT in repository

File `lib/firebase_options.dart` berisi API keys yang sensitif dan **tidak boleh di-commit** ke repository.

## 📋 Setup Instructions untuk Developer

### 1. Copy Template
```bash
# Copy template file ke firebase_options.dart
copy lib/firebase_options.template.dart lib/firebase_options.dart
```

### 2. Get Firebase Configuration

#### Option A: Google Cloud Console (Recommended)
1. Buka https://console.cloud.google.com/apis/credentials
2. Pilih project: `app-project-25`
3. Copy API Keys untuk setiap platform

#### Option B: Firebase Console
1. Buka https://console.firebase.google.com/
2. Pilih project: `app-project-25`
3. Settings → General → Your apps
4. Download config files

### 3. Update firebase_options.dart

Replace semua placeholder dengan values yang sebenarnya:

```dart
// REPLACE THESE VALUES:
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_ACTUAL_WEB_API_KEY',      // ← Dari Cloud Console
  appId: 'YOUR_ACTUAL_WEB_APP_ID',        // ← Dari Firebase Console
  messagingSenderId: '1053164425613',      // ← Project sender ID
  projectId: 'app-project-25',            // ← Project ID
  authDomain: 'app-project-25.firebaseapp.com',
  storageBucket: 'app-project-25.firebasestorage.app',
);
```

### 4. Verify Setup

```bash
# Test compile
flutter analyze

# Test run
flutter run
```

## 🛡️ Security Notes

### ✅ What's Safe:
- `firebase_options.template.dart` - Template dengan placeholder
- Dokumentasi dan guides
- Konfigurasi project (pubspec.yaml, dll)

### ❌ NEVER Commit:
- `firebase_options.dart` - File dengan API keys asli
- `.env` files dengan credentials
- Config files dengan secrets

## 🔍 Troubleshooting

### "No Firebase App" Error
- Check `projectId` benar di firebase_options.dart
- Pastikan Firebase initialized di main.dart

### "Invalid API Key" Error  
- Pastikan API key tidak ada spasi extra
- Check API key restrictions di Google Cloud Console

### "App not found" Error
- Check `appId` format benar
- Pastikan app sudah dibuat di Firebase Console

## 📞 Support

Jika ada masalah setup:
1. Check dokumentasi di `/docs` folder
2. Verify `.gitignore` berisi `lib/firebase_options.dart`
3. Pastikan template file tersedia

---

⚠️ **REMEMBER**: File `firebase_options.dart` harus dibuat manual oleh setiap developer berdasarkan template ini.