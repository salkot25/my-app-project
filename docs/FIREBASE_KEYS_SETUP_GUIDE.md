# 🔑 FIREBASE KEYS SETUP GUIDE

## 🚨 URGENT: Generate New Firebase API Keys

### Step 1: Akses Firebase Console

1. **Buka browser** dan kunjungi: https://console.firebase.google.com/
2. **Login** dengan akun Google yang memiliki akses ke project
3. **Pilih project**: `app-project-25`

### Step 2: Revoke Old Keys (WAJIB!)

**⚠️ Keys yang HARUS di-revoke:**

```
Web API Key:     AIzaSyBRWp5N6va7lcVw2Uk2zH0ydG-tl4bNP2k
Android API Key: AIzaSyAiq2naEuacBLPb3g0pZ2e3mef-V0XRe6c
iOS API Key:     AIzaSyCuiLMutKDdedh8SP1HJPtP4iBCygRk790
```

**Cara revoke:**

1. Di Firebase Console → **Settings** (⚙️) → **General**
2. Scroll ke bagian **Your apps**
3. Untuk setiap app (Web, Android, iOS):
   - Klik **⚙️ Settings** di sebelah app
   - Klik **Delete app** ATAU **Regenerate config**
   - Konfirmasi deletion/regeneration

### Step 3: Create New Apps (Jika dihapus)

#### 🌐 Web App:

1. Klik **Add app** → **Web** (</> icon)
2. **App nickname**: `My Project Web`
3. ✅ Check **Also set up Firebase Hosting**
4. Klik **Register app**
5. **COPY** konfigurasi yang muncul

#### 📱 Android App:

1. Klik **Add app** → **Android** (Android icon)
2. **Android package name**: `com.example.myProject` (atau sesuai yang lama)
3. **App nickname**: `My Project Android`
4. Klik **Register app**
5. **Download** `google-services.json`
6. **COPY** konfigurasi dari SDK setup

#### 🍎 iOS App:

1. Klik **Add app** → **iOS** (Apple icon)
2. **iOS bundle ID**: `com.example.myProject` (atau sesuai yang lama)
3. **App nickname**: `My Project iOS`
4. Klik **Register app**
5. **Download** `GoogleService-Info.plist`
6. **COPY** konfigurasi dari SDK setup

### Step 4: Update firebase_options.dart

Buka file `lib/firebase_options.dart` dan ganti placeholder dengan keys baru:

```dart
// GANTI SEMUA PLACEHOLDER INI:

// Web Configuration
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'PASTE_YOUR_NEW_WEB_API_KEY_HERE',           // Dari Web App config
  appId: 'PASTE_YOUR_NEW_WEB_APP_ID_HERE',             // Dari Web App config
  messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',      // Dari project settings
  projectId: 'app-project-25',                         // Sama seperti sebelumnya
  authDomain: 'app-project-25.firebaseapp.com',       // Sama seperti sebelumnya
  storageBucket: 'app-project-25.firebasestorage.app', // Sama seperti sebelumnya
);

// Android Configuration
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'PASTE_YOUR_NEW_ANDROID_API_KEY_HERE',       // Dari Android App config
  appId: 'PASTE_YOUR_NEW_ANDROID_APP_ID_HERE',         // Dari Android App config
  messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',      // Sama dengan Web
  projectId: 'app-project-25',                         // Sama seperti sebelumnya
  storageBucket: 'app-project-25.firebasestorage.app', // Sama seperti sebelumnya
);

// iOS Configuration
static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'PASTE_YOUR_NEW_IOS_API_KEY_HERE',           // Dari iOS App config
  appId: 'PASTE_YOUR_NEW_IOS_APP_ID_HERE',             // Dari iOS App config
  messagingSenderId: 'PASTE_YOUR_SENDER_ID_HERE',      // Sama dengan Web
  projectId: 'app-project-25',                         // Sama seperti sebelumnya
  storageBucket: 'app-project-25.firebasestorage.app', // Sama seperti sebelumnya
  iosBundleId: 'com.example.myProject',                // Bundle ID iOS app
);
```

### Step 5: Dimana Mendapatkan Keys

#### 📍 Web API Key & App ID:

```javascript
// Akan muncul seperti ini di Firebase Console:
const firebaseConfig = {
  apiKey: "AIzaSyC...", // ← COPY INI untuk Web API Key
  authDomain: "app-project-25.firebaseapp.com",
  projectId: "app-project-25",
  storageBucket: "app-project-25.firebasestorage.app",
  messagingSenderId: "1053164425613",
  appId: "1:1053164425613:web:abc123", // ← COPY INI untuk Web App ID
};
```

#### 📍 Android API Key & App ID:

Dari `google-services.json`:

```json
{
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "1:1053164425613:android:xyz789" // ← Android App ID
      },
      "api_key": [
        {
          "current_key": "AIzaSyB..." // ← Android API Key
        }
      ]
    }
  ]
}
```

#### 📍 iOS API Key & App ID:

Dari `GoogleService-Info.plist`:

```xml
<key>API_KEY</key>
<string>AIzaSyA...</string>     <!-- iOS API Key -->
<key>GOOGLE_APP_ID</key>
<string>1:1053164425613:ios:def456</string>  <!-- iOS App ID -->
```

### Step 6: Test Setup

Setelah mengisi semua keys:

```bash
# Test compile
flutter analyze

# Test run
flutter run
```

### 🔍 Troubleshooting

**Jika ada error saat run:**

1. **"No Firebase App"** → Check projectId benar
2. **"Invalid API Key"** → Pastikan copy paste benar, tidak ada spasi extra
3. **"App not found"** → Pastikan App ID format benar dengan platform

### ✅ Verification Checklist

- [ ] Old keys sudah di-revoke di Firebase Console
- [ ] New Web app created & configured
- [ ] New Android app created & configured
- [ ] New iOS app created & configured
- [ ] All keys di firebase_options.dart sudah diganti
- [ ] flutter analyze berjalan tanpa error
- [ ] flutter run berhasil tanpa Firebase errors

---

**⚠️ REMEMBER:** File `firebase_options.dart` sudah ada di `.gitignore`, jadi keys baru tidak akan ter-commit ke repository!
