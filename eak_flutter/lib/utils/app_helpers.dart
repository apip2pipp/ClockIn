import 'package:shared_preferences/shared_preferences.dart';

/// Helper class untuk mengelola onboarding preferences
/// Gunakan class ini untuk check, set, dan reset status onboarding
class OnboardingPreferences {
  static const String _keyHasSeenOnboarding = 'hasSeenOnboarding';

  /// Check apakah user sudah pernah melihat onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Set status onboarding sebagai sudah dilihat
  static Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  /// Reset status onboarding (untuk testing atau force show onboarding)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasSeenOnboarding);
  }

  /// Clear all preferences (use with caution!)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

/// Helper class untuk app navigation
class AppRouter {
  /// Navigate to home screen (TODO: implement when home screen is ready)
  static void navigateToHome(context) {
    // Navigator.of(context).pushReplacementNamed('/home');
  }

  /// Navigate to login screen (TODO: implement when login screen is ready)
  static void navigateToLogin(context) {
    // Navigator.of(context).pushReplacementNamed('/login');
  }

  /// Navigate to onboarding screen
  static void navigateToOnboarding(context) {
    // Navigator.of(context).pushReplacement(
    //   MaterialPageRoute(
    //     builder: (context) => const OnboardingScreen(),
    //   ),
    // );
  }
}

/// Helper class untuk app constants
class AppConstants {
  // Splash screen duration
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration splashFadeDuration = Duration(milliseconds: 1500);

  // Onboarding
  static const Duration onboardingPageTransition = Duration(milliseconds: 500);
  static const int onboardingPageCount = 4;

  // Colors
  static const int colorBlue = 0xFF4A90E2;
  static const int colorGreen = 0xFF50C878;
  static const int colorRed = 0xFFFF6B6B;
  static const int colorOrange = 0xFFFFB84D;

  // Asset paths
  static const String splashImagePath = 'assets/splashScreen/splash-screen.png';
  static const String onboarding1 = 'assets/onboarding/onboarding-1.png';
  static const String onboarding2 = 'assets/onboarding/onboarding-2.png';
  static const String onboarding3 = 'assets/onboarding/onboarding-3.png';
  static const String onboarding4 = 'assets/onboarding/onboarding-4.png';
}
