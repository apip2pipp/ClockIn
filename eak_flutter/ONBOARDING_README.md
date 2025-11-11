# Implementasi Onboarding Screen

## Overview
Onboarding screen telah diimplementasikan dengan modern design dan smooth animations menggunakan:
- **PageView** - untuk horizontal scrolling antar halaman
- **SmoothPageIndicator** - untuk animated page indicators
- **SharedPreferences** - untuk menyimpan status onboarding
- **4 Onboarding Pages** - sesuai dengan assets yang tersedia

## Fitur Utama

### 1. **4 Halaman Onboarding**
Setiap halaman memiliki:
- **Gambar ilustrasi** dari `assets/onboarding/`
- **Judul** yang menggambarkan fitur
- **Subtitle** dengan deskripsi detail
- **Warna tema** yang berbeda untuk setiap halaman

### 2. **Navigasi yang Smooth**
- **Skip Button** - untuk langsung ke halaman terakhir
- **Next Button** - untuk ke halaman selanjutnya
- **Get Started Button** - muncul di halaman terakhir
- **Swipe Gesture** - support swipe horizontal

### 3. **Animated Page Indicator**
- Menggunakan `ExpandingDotsEffect`
- Warna berubah sesuai dengan halaman aktif
- Smooth transition antar dots

### 4. **State Management**
- Menyimpan status onboarding dengan SharedPreferences
- Key: `hasSeenOnboarding`
- Mencegah onboarding muncul lagi setelah selesai

## Struktur File

```
lib/
  screens/
    onboarding_screen.dart    # Main onboarding screen
    splash_screen.dart        # Check onboarding status
```

## Halaman Onboarding

### Halaman 1 - Welcome
- **Image**: `onboarding-1.png`
- **Title**: "Welcome to ClockIn"
- **Subtitle**: "Your smart attendance management solution"
- **Color**: Blue (#4A90E2)

### Halaman 2 - Easy Attendance
- **Image**: `onboarding-2.png`
- **Title**: "Easy Attendance"
- **Subtitle**: "Clock in and out with just one tap, anytime, anywhere"
- **Color**: Green (#50C878)

### Halaman 3 - Track Your Time
- **Image**: `onboarding-3.png`
- **Title**: "Track Your Time"
- **Subtitle**: "Monitor your working hours and attendance history"
- **Color**: Red (#FF6B6B)

### Halaman 4 - Real-time Reports
- **Image**: `onboarding-4.png`
- **Title**: "Real-time Reports"
- **Subtitle**: "Get instant updates and detailed attendance reports"
- **Color**: Orange (#FFB84D)

## User Flow

```
App Launch
    ↓
Splash Screen
    ↓
Check hasSeenOnboarding
    ↓
    ├─ false → Onboarding Screen (4 pages)
    │             ↓
    │        Get Started
    │             ↓
    │     Set hasSeenOnboarding = true
    │             ↓
    └─ true → Home/Login Screen (TODO)
```

## Customization

### Mengubah Konten Onboarding

Edit di `onboarding_screen.dart`:

```dart
final List<OnboardingData> _pages = [
  OnboardingData(
    image: 'path/to/image.png',
    title: 'Your Title',
    subtitle: 'Your subtitle description',
    color: Color(0xFFHEXCODE),
  ),
  // Tambah atau kurangi halaman di sini
];
```

### Mengubah Warna Tema

Edit warna di setiap `OnboardingData`:

```dart
color: Color(0xFF4A90E2), // Ubah hex code
```

### Mengubah Page Indicator Style

Edit di `SmoothPageIndicator`:

```dart
effect: ExpandingDotsEffect(
  activeDotColor: _pages[currentIndex].color,
  dotColor: Colors.grey[300]!,
  dotHeight: 8,        // Tinggi dot
  dotWidth: 8,         // Lebar dot
  expansionFactor: 4,  // Faktor expansion
  spacing: 8,          // Jarak antar dots
),
```

### Mengubah Button Style

Edit di `ElevatedButton`:

```dart
style: ElevatedButton.styleFrom(
  backgroundColor: color,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16), // Ubah radius
  ),
  elevation: 0, // Ubah elevation
),
```

## Testing

Run aplikasi untuk test onboarding:

```bash
flutter run
```

Reset onboarding status (untuk test ulang):

```dart
// Tambahkan tombol di home screen untuk reset:
final prefs = await SharedPreferences.getInstance();
await prefs.remove('hasSeenOnboarding');
```

## Todo untuk Pengembangan

1. ✅ Implementasi 4 halaman onboarding
2. ✅ Setup assets dan images
3. ✅ Animated page indicators
4. ✅ Skip dan navigation buttons
5. ✅ SharedPreferences integration
6. ⏳ **Navigate ke Home/Login screen** (perlu dibuat)
7. ⏳ **Animasi transisi yang lebih advanced** (optional)
8. ⏳ **Localization support** (optional)

## Dependencies Used

```yaml
dependencies:
  smooth_page_indicator: ^1.2.1
  shared_preferences: ^2.5.3
```

## Best Practices

1. **Image Optimization**: Pastikan images di `assets/onboarding/` sudah dioptimasi
2. **Responsive Design**: Layout sudah responsive untuk berbagai ukuran layar
3. **Accessibility**: Gunakan semantic widgets untuk screen readers
4. **Performance**: Images di-load secara lazy per halaman
5. **State Management**: Gunakan SharedPreferences untuk persistent state
