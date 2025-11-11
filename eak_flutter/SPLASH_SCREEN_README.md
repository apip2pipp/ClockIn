# Implementasi Splash Screen

## Overview
Splash screen telah diimplementasikan menggunakan kombinasi:
1. **Flutter Native Splash** - untuk native splash screen di Android & iOS
2. **Custom Splash Screen Widget** - untuk transisi yang smooth ke onboarding

## File yang Dimodifikasi/Dibuat

### 1. `flutter_native_splash.yaml`
Konfigurasi untuk generate native splash screen yang akan muncul saat app pertama kali dibuka.

**Fitur:**
- Menggunakan gambar dari `assets/splashScreen/splash-screen.png`
- Support untuk Android 12+
- Support untuk dark mode
- Fullscreen mode

### 2. `lib/screens/splash_screen.dart` (Baru)
Custom splash screen widget dengan fitur:
- **Fade animation** untuk transisi smooth
- **Timer 3 detik** sebelum navigasi ke screen berikutnya
- **Check onboarding status** menggunakan SharedPreferences
- Navigasi otomatis ke Onboarding Screen

### 3. `lib/main.dart`
Diupdate untuk:
- Menggunakan `SplashScreen` sebagai home screen
- Set orientation ke portrait
- Konfigurasi status bar (transparent)

### 4. `pubspec.yaml`
Ditambahkan asset path:
- `assets/splashScreen/`
- `assets/onboarding/`

## Cara Kerja

1. **App Launch** → Native Splash muncul (instant)
2. **Flutter Initialized** → Custom SplashScreen widget muncul dengan fade animation
3. **After 3 seconds** → Check apakah user sudah pernah lihat onboarding
4. **Navigate** → Ke Onboarding atau Home screen

## Customization

### Mengubah Durasi Splash
Edit di `splash_screen.dart`:
```dart
await Future.delayed(const Duration(seconds: 3)); // ubah durasi di sini
```

### Mengubah Animasi
Edit di `splash_screen.dart`:
```dart
_animationController = AnimationController(
  vsync: this,
  duration: const Duration(milliseconds: 1500), // ubah durasi animasi
);
```

### Mengubah Background Color
Edit di `flutter_native_splash.yaml`:
```yaml
color: "#ffffff"  # ubah hex color di sini
```

## Testing

Untuk test splash screen:
```bash
flutter run
```

Untuk regenerate native splash (jika ada perubahan pada konfigurasi):
```bash
dart run flutter_native_splash:create
```

## Notes

- Splash screen image harus memiliki resolusi yang cukup tinggi untuk berbagai ukuran layar
- Untuk production, pertimbangkan untuk membuat variants (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
- Native splash akan hilang begitu Flutter engine ready
- Custom splash screen memberikan kontrol lebih untuk transisi
