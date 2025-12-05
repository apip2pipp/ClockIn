# 📱 Flutter Mobile App - Production Build Guide

## 🎯 Overview

Panduan untuk build Flutter mobile app ke production dan connect ke server https://clockin.cloud

---

## ✅ Perubahan yang Sudah Dilakukan

### 1. **API Configuration** - `lib/config/api_config.dart`

```dart
// PRODUCTION (Active)
static const String baseUrl = 'https://clockin.cloud/api';
static const String storageUrl = 'https://clockin.cloud/storage';

// DEVELOPMENT (Commented out)
// static const String baseUrl = 'http://192.168.18.67:8000/api';
// static const String storageUrl = 'http://192.168.18.67:8000/storage';
```

### 2. **Login Screen** - `lib/screens/login_screen.dart`

```dart
// Register URL (PRODUCTION)
static const String _registerWebUrl = 'https://clockin.cloud/register';

// DEVELOPMENT (Commented out)
// static const String _registerWebUrl = 'http://192.168.18.67:8000/register';
```

---

## 🏗️ Build Production APK

### Prerequisites:

```bash
# Check Flutter version
flutter --version

# Should be Flutter 3.0+ for best compatibility
```

### Build Steps:

```bash
# 1. Pindah ke directory Flutter
cd eak_flutter

# 2. Clean previous build
flutter clean

# 3. Get dependencies
flutter pub get

# 4. Build APK (Release)
flutter build apk --release

# Output location:
# build/app/outputs/flutter-apk/app-release.apk
```

### Build App Bundle (untuk Google Play Store):

```bash
# Build AAB
flutter build appbundle --release

# Output location:
# build/app/outputs/bundle/release/app-release.aab
```

---

## 📦 APK Output

Setelah build, APK akan ada di:
```
eak_flutter/build/app/outputs/flutter-apk/app-release.apk
```

**File size**: ~40-60 MB (tergantung dependencies)

---

## 🧪 Testing Production Build

### 1. Install APK di Device

```bash
# Via ADB (USB)
adb install build/app/outputs/flutter-apk/app-release.apk

# Atau transfer APK ke HP dan install manual
```

### 2. Test Checklist

- [ ] **Login**: Bisa login dengan user dari production database
- [ ] **API Connection**: Check log tidak ada error connection
- [ ] **Clock In**: Bisa absen masuk dengan GPS & selfie
- [ ] **Clock Out**: Bisa absen keluar
- [ ] **History**: Data kehadiran muncul dari server
- [ ] **Leave Request**: Bisa submit izin/cuti
- [ ] **Profile**: Data profile load dari API
- [ ] **Photo Upload**: Foto selfie ter-upload ke server
- [ ] **Register Link**: Link register buka https://clockin.cloud/register

---

## 🔄 Switch Between Development & Production

### Switch to Development (Local Testing):

**File**: `lib/config/api_config.dart`

```dart
// Comment production, uncomment development
// static const String baseUrl = 'https://clockin.cloud/api';
static const String baseUrl = 'http://192.168.18.67:8000/api'; // Ganti IP sesuai laptop

// static const String storageUrl = 'https://clockin.cloud/storage';
static const String storageUrl = 'http://192.168.18.67:8000/storage';
```

**File**: `lib/screens/login_screen.dart`

```dart
// Comment production, uncomment development
// static const String _registerWebUrl = 'https://clockin.cloud/register';
static const String _registerWebUrl = 'http://192.168.18.67:8000/register';
```

Then:
```bash
flutter clean
flutter pub get
flutter run
```

### Switch to Production:

**File**: `lib/config/api_config.dart`

```dart
// Uncomment production, comment development
static const String baseUrl = 'https://clockin.cloud/api';
// static const String baseUrl = 'http://192.168.18.67:8000/api';

static const String storageUrl = 'https://clockin.cloud/storage';
// static const String storageUrl = 'http://192.168.18.67:8000/storage';
```

**File**: `lib/screens/login_screen.dart`

```dart
static const String _registerWebUrl = 'https://clockin.cloud/register';
// static const String _registerWebUrl = 'http://192.168.18.67:8000/register';
```

Then:
```bash
flutter clean
flutter pub get
flutter build apk --release
```

---

## 🐛 Common Issues

### Issue 1: "Failed to connect to API"

**Cause**: Backend API tidak accessible atau SSL certificate issue

**Solution**:
1. Check backend running: `https://clockin.cloud/api`
2. Test di browser: `https://clockin.cloud/api/profile` (should return 401 Unauthenticated)
3. Check SSL valid (no certificate errors)

### Issue 2: "Certificate verification failed"

**Cause**: SSL certificate tidak trusted oleh Android

**Solution**:
- Pastikan SSL certificate valid (Let's Encrypt OK)
- Jangan pakai self-signed certificate untuk production
- Check certificate: https://www.ssllabs.com/ssltest/analyze.html?d=clockin.cloud

### Issue 3: "Network error" di production APK

**Cause**: Android mengharuskan HTTPS untuk network request (cleartext not allowed)

**Solution**:
- Pastikan `baseUrl` pakai `https://` bukan `http://`
- Check `android/app/src/main/AndroidManifest.xml`:
  ```xml
  <application
      android:usesCleartextTraffic="false">  <!-- Should be false for production -->
  ```

### Issue 4: Photo upload gagal

**Cause**: Storage URL salah atau permission issue

**Solution**:
1. Check `storageUrl` di `api_config.dart` sudah benar
2. Check backend storage folder writable:
   ```bash
   chmod -R 775 /var/www/clockin.cloud/storage/app/public
   ```
3. Check symlink:
   ```bash
   cd /var/www/clockin.cloud
   php artisan storage:link
   ```

---

## 📊 Build Configuration

### Release Build Settings

**File**: `android/app/build.gradle`

```gradle
android {
    defaultConfig {
        applicationId "com.clockin.app"  // Sesuaikan dengan app ID
        minSdkVersion 21
        targetSdkVersion 34
        versionCode 1
        versionName "1.0.0"
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release  // If using signing
            minifyEnabled true
            shrinkResources true
        }
    }
}
```

### App Signing (Optional, untuk Play Store)

1. Generate keystore:
```bash
keytool -genkey -v -keystore ~/clockin-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias clockin
```

2. Create `android/key.properties`:
```properties
storePassword=yourStorePassword
keyPassword=yourKeyPassword
keyAlias=clockin
storeFile=/path/to/clockin-release-key.jks
```

3. Update `android/app/build.gradle`:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
}
```

---

## 📱 Distribution

### Option 1: Direct APK Installation
- Share `app-release.apk` via Google Drive / WhatsApp
- User install APK directly (need "Unknown sources" enabled)

### Option 2: Google Play Store (Recommended)
1. Create Google Play Developer account ($25 one-time)
2. Upload `app-release.aab`
3. Complete store listing
4. Publish

### Option 3: Internal Testing
1. Use Firebase App Distribution
2. Upload APK to Firebase
3. Share testing link to testers

---

## ✅ Production Checklist

Before distributing to users:

- [ ] API config pointing to production: `https://clockin.cloud/api`
- [ ] Storage URL correct: `https://clockin.cloud/storage`
- [ ] Register URL correct: `https://clockin.cloud/register`
- [ ] SSL certificate valid (HTTPS working)
- [ ] Backend API accessible from internet
- [ ] Test login with production user
- [ ] Test clock in/out functionality
- [ ] Test photo upload
- [ ] Test leave request submission
- [ ] Check app doesn't crash on real device
- [ ] Build release APK: `flutter build apk --release`
- [ ] APK size reasonable (< 100 MB)
- [ ] No debug print/logs in release build
- [ ] App icon & splash screen correct

---

## 🎯 Environment Summary

### Production:
```dart
API: https://clockin.cloud/api
Storage: https://clockin.cloud/storage
Register: https://clockin.cloud/register
```

### Development (Local):
```dart
API: http://YOUR_LOCAL_IP:8000/api
Storage: http://YOUR_LOCAL_IP:8000/storage
Register: http://YOUR_LOCAL_IP:8000/register
```

---

## 📞 Support

Jika ada masalah saat build atau testing:

1. Check Flutter doctor: `flutter doctor -v`
2. Clean build: `flutter clean && flutter pub get`
3. Check logs: `flutter logs` atau `adb logcat`
4. Verify API accessible: Test di Postman/browser

---

**Last Updated**: December 5, 2025  
**Flutter Version**: 3.x  
**Status**: ✅ Ready for Production Build
