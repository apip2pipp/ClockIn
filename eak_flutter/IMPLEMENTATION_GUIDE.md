# ClockIn App - Splash & Onboarding Implementation Guide

## 📱 Overview

Proyek ini sudah mengimplementasikan Splash Screen dan Onboarding Screen yang lengkap dengan animasi dan user experience yang baik.

## 🎯 Fitur yang Sudah Diimplementasikan

### ✅ Splash Screen
- Native splash screen (Android & iOS)
- Custom splash screen dengan fade animation
- Timer 3 detik sebelum navigasi
- Check status onboarding
- Support untuk Android 12+
- Dark mode support

### ✅ Onboarding Screen
- 4 halaman onboarding dengan konten berbeda
- Smooth page transition
- Animated page indicators (expanding dots)
- Skip button untuk langsung ke akhir
- Next/Back navigation
- Get Started button di halaman terakhir
- SharedPreferences untuk menyimpan status
- Responsive design untuk berbagai ukuran layar

## 📁 Struktur File

```
eak_flutter/
├── lib/
│   ├── main.dart                          # Entry point app
│   ├── screens/
│   │   ├── splash_screen.dart             # Splash screen utama
│   │   ├── onboarding_screen.dart         # Onboarding screen utama (AKTIF)
│   │   └── onboarding_screen_v2.dart      # Onboarding alternatif dengan features list
│   └── widgets/
│       └── onboarding_widgets.dart        # Reusable widgets untuk onboarding
├── assets/
│   ├── splashScreen/
│   │   └── splash-screen.png              # Gambar splash screen
│   └── onboarding/
│       ├── onboarding-1.png               # Welcome page
│       ├── onboarding-2.png               # Easy Attendance page
│       ├── onboarding-3.png               # Track Time page
│       └── onboarding-4.png               # Reports page
├── pubspec.yaml                           # Dependencies & assets
├── flutter_native_splash.yaml             # Native splash config
├── SPLASH_SCREEN_README.md                # Dokumentasi splash screen
└── ONBOARDING_README.md                   # Dokumentasi onboarding

```

## 🚀 User Flow

```
1. App Launch
   ↓
2. Native Splash (instant load)
   ↓
3. Custom Splash Screen (3 detik dengan fade animation)
   ↓
4. Check hasSeenOnboarding dari SharedPreferences
   ↓
   ├─ false → Onboarding Screen (4 pages)
   │          User swipe/next → Halaman 1-4
   │          User tap "Get Started"
   │          Set hasSeenOnboarding = true
   │          ↓
   └─ true → Home/Login Screen (TODO)
```

## 🎨 Onboarding Pages Content

| Page | Image | Title | Subtitle | Color |
|------|-------|-------|----------|-------|
| 1 | onboarding-1.png | Welcome to ClockIn | Your smart attendance management solution | Blue #4A90E2 |
| 2 | onboarding-2.png | Easy Attendance | Clock in and out with just one tap | Green #50C878 |
| 3 | onboarding-3.png | Track Your Time | Monitor your working hours and attendance history | Red #FF6B6B |
| 4 | onboarding-4.png | Real-time Reports | Get instant updates and detailed attendance reports | Orange #FFB84D |

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8
  flutter_native_splash: ^2.4.7      # Native splash screen
  smooth_page_indicator: ^1.2.1      # Animated page indicators
  shared_preferences: ^2.5.3         # Persistent storage

dev_dependencies:
  flutter_launcher_icons: ^0.14.4    # App icons
```

## 🛠️ Commands

### Install Dependencies
```bash
cd eak_flutter
flutter pub get
```

### Generate Native Splash
```bash
dart run flutter_native_splash:create
```

### Run Application
```bash
flutter run
```

### Build for Production
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 🔧 Kustomisasi

### 1. Mengubah Durasi Splash Screen

Edit `lib/screens/splash_screen.dart`:

```dart
// Ubah durasi di baris ini:
await Future.delayed(const Duration(seconds: 3)); // 3 detik
```

### 2. Menambah/Mengurangi Halaman Onboarding

Edit `lib/screens/onboarding_screen.dart`:

```dart
final List<OnboardingData> _pages = [
  OnboardingData(
    image: 'assets/onboarding/onboarding-5.png',
    title: 'New Feature',
    subtitle: 'Description here',
    color: Color(0xFF123456),
  ),
  // Tambahkan lebih banyak halaman
];
```

### 3. Mengubah Warna Tema

Setiap halaman bisa memiliki warna berbeda:

```dart
color: Color(0xFFHEXCODE), // Ganti dengan hex color
```

### 4. Mengubah Style Page Indicator

Edit di `SmoothPageIndicator`:

```dart
effect: ExpandingDotsEffect(
  activeDotColor: activeColor,
  dotColor: inactiveColor,
  dotHeight: 8,
  dotWidth: 8,
  expansionFactor: 4,
  spacing: 8,
),
```

Atau gunakan effect lain:
- `WormEffect` - indicator seperti cacing
- `JumpingDotEffect` - dots melompat
- `ScrollingDotsEffect` - dots bergerak
- `SlideEffect` - sliding effect

### 5. Reset Onboarding (untuk Testing)

Tambahkan code ini di screen manapun untuk reset:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.remove('hasSeenOnboarding');
// Restart app untuk melihat onboarding lagi
```

## 🎨 Alternatif Design

Jika ingin menggunakan design alternatif yang lebih advanced:

1. Buka `lib/main.dart`
2. Ubah import di `splash_screen.dart`:

```dart
// Dari:
import 'onboarding_screen.dart';

// Ke:
import 'onboarding_screen_v2.dart';

// Dan ubah navigasi:
Navigator.of(context).pushReplacement(
  MaterialPageRoute(
    builder: (context) => const OnboardingScreenV2(), // Gunakan V2
  ),
);
```

**OnboardingScreenV2** memiliki fitur tambahan:
- Gradient background
- Features list untuk setiap page
- Back button untuk navigasi mundur
- Progress counter (1/4, 2/4, dst)
- Hero animation
- Fade transition antar halaman

## 📝 TODO List

### Completed ✅
- [x] Setup native splash screen
- [x] Implement custom splash screen
- [x] Create 4 onboarding pages
- [x] Add smooth page indicators
- [x] Implement SharedPreferences
- [x] Add skip functionality
- [x] Create alternative design (V2)
- [x] Add reusable widgets

### Upcoming 🔜
- [ ] Create Home/Login screen
- [ ] Add navigation to Home from onboarding
- [ ] Implement authentication flow
- [ ] Add loading states
- [ ] Implement localization (multi-language)
- [ ] Add analytics tracking
- [ ] Unit tests for splash & onboarding

## 🐛 Troubleshooting

### Splash screen tidak muncul
```bash
# Regenerate splash screen
dart run flutter_native_splash:create

# Clean dan rebuild
flutter clean
flutter pub get
flutter run
```

### Assets tidak ditemukan
Pastikan `pubspec.yaml` sudah include assets:
```yaml
flutter:
  assets:
    - assets/splashScreen/
    - assets/onboarding/
```

### Onboarding terus muncul
```dart
// Reset SharedPreferences
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('hasSeenOnboarding', true);
```

## 📚 Referensi

- [Flutter Native Splash](https://pub.dev/packages/flutter_native_splash)
- [Smooth Page Indicator](https://pub.dev/packages/smooth_page_indicator)
- [SharedPreferences](https://pub.dev/packages/shared_preferences)
- [Flutter Documentation](https://flutter.dev/docs)

## 🤝 Contributing

Jika ada bug atau saran improvement:
1. Create issue di repository
2. Fork dan create pull request
3. Update dokumentasi jika perlu

## 📄 License

Project ini menggunakan lisensi sesuai dengan repository utama.

---

**Happy Coding! 🚀**

Jika ada pertanyaan, silakan hubungi tim development.
