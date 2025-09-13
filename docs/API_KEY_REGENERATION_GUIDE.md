# 🔑 API KEY REGENERATION - ALTERNATIVE APPROACH

## ⚠️ DISCOVERY: Firebase CLI Limitations

Setelah testing dengan Firebase CLI, ternyata:

1. ❌ **Firebase CLI tidak bisa delete apps**
2. ❌ **Firebase CLI tidak bisa regenerate API keys**
3. ❌ **Apps baru masih menggunakan keys ter-expose yang sama**

**Root cause:** Firebase menggunakan **project-level API keys** yang dibagi untuk semua apps dalam project yang sama.

## ✅ SOLUSI YANG BENAR

### Option A: Google Cloud Console (RECOMMENDED)

#### Step 1: Buka Google Cloud Console

```
🌐 https://console.cloud.google.com/
```

#### Step 2: Pilih Project

- Project: `app-project-25`
- Project Number: `1053164425613`

#### Step 3: API & Services → Credentials

```
https://console.cloud.google.com/apis/credentials?project=app-project-25
```

#### Step 4: Regenerate API Keys

1. **Find exposed keys:**

   - `AIzaSyBRWp5N6va7lcVw2Uk2zH0ydG-tl4bNP2k` (Web/Browser key)
   - `AIzaSyAiq2naEuacBLPb3g0pZ2e3mef-V0XRe6c` (Android key)
   - `AIzaSyCuiLMutKDdedh8SP1HJPtP4iBCygRk790` (iOS key)

2. **For each key:**
   - Click on key name
   - Click **⚙️ Regenerate Key**
   - **Copy new key**
   - Update `firebase_options.dart`

#### Step 5: Update Restrictions (Security)

For each new key, add restrictions:

**Web Key:**

- HTTP referrers: `app-project-25.firebaseapp.com/*`
- APIs: Firebase services only

**Android Key:**

- Package name: `com.example.myProject`
- SHA-1: Your Android signing certificate
- APIs: Firebase services only

**iOS Key:**

- Bundle ID: `com.example.myProject`
- APIs: Firebase services only

### Option B: Create New Firebase Project (CLEAN SLATE)

#### Jika Option A terlalu kompleks:

1. **Create new project:** `app-project-25-secure`
2. **Migrate data** (if any)
3. **Update Flutter app** to use new project
4. **Delete old project** dengan exposed keys

## 🎯 RECOMMENDATION

**Pilih Option A** (Google Cloud Console) karena:

- ✅ Faster implementation
- ✅ No data migration needed
- ✅ Clean key regeneration
- ✅ Proper security restrictions

## 📋 FILES TO UPDATE

Setelah mendapat keys baru:

```dart
// firebase_options.dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'NEW_REGENERATED_WEB_KEY',     // ← From Cloud Console
  appId: '1:1053164425613:web:5e5b4049f280a594476dc4', // ← New from CLI
  // ... rest stays same
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'NEW_REGENERATED_ANDROID_KEY', // ← From Cloud Console
  appId: '1:1053164425613:android:62e73b684f602490476dc4', // ← New from CLI
  // ... rest stays same
);
```

## ⏭️ NEXT STEPS

1. **Buka Google Cloud Console**
2. **Regenerate API keys** untuk Web, Android, iOS
3. **Update firebase_options.dart** dengan keys baru
4. **Test aplikasi** dengan `flutter run`

**Mau saya bantu buka Google Cloud Console atau ada pertanyaan lain?**
