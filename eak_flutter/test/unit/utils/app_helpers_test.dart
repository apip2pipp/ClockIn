import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/utils/app_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('OnboardingPreferences', () {
    setUp(() {
      // Initialize SharedPreferences with empty state
      SharedPreferences.setMockInitialValues({});
    });

    group('hasSeenOnboarding', () {
      test('should return false when onboarding not seen', () async {
        final result = await OnboardingPreferences.hasSeenOnboarding();
        expect(result, false);
      });

      test('should return true when onboarding has been seen', () async {
        await OnboardingPreferences.setOnboardingComplete();
        final result = await OnboardingPreferences.hasSeenOnboarding();
        expect(result, true);
      });

      test('should handle multiple calls consistently', () async {
        final result1 = await OnboardingPreferences.hasSeenOnboarding();
        final result2 = await OnboardingPreferences.hasSeenOnboarding();
        expect(result1, result2);
      });
    });

    group('setOnboardingComplete', () {
      test('should set onboarding as complete', () async {
        await OnboardingPreferences.setOnboardingComplete();
        final result = await OnboardingPreferences.hasSeenOnboarding();
        expect(result, true);
      });

      test('should persist onboarding complete state', () async {
        await OnboardingPreferences.setOnboardingComplete();

        // Check multiple times
        expect(await OnboardingPreferences.hasSeenOnboarding(), true);
        expect(await OnboardingPreferences.hasSeenOnboarding(), true);
      });

      test('should not throw error on repeated calls', () async {
        expect(() async {
          await OnboardingPreferences.setOnboardingComplete();
          await OnboardingPreferences.setOnboardingComplete();
          await OnboardingPreferences.setOnboardingComplete();
        }, returnsNormally);
      });
    });

    group('resetOnboarding', () {
      test('should reset onboarding status to false', () async {
        await OnboardingPreferences.setOnboardingComplete();
        expect(await OnboardingPreferences.hasSeenOnboarding(), true);

        await OnboardingPreferences.resetOnboarding();
        expect(await OnboardingPreferences.hasSeenOnboarding(), false);
      });

      test('should work when onboarding was never set', () async {
        expect(() => OnboardingPreferences.resetOnboarding(), returnsNormally);
      });

      test('should allow re-setting after reset', () async {
        await OnboardingPreferences.setOnboardingComplete();
        await OnboardingPreferences.resetOnboarding();
        await OnboardingPreferences.setOnboardingComplete();

        expect(await OnboardingPreferences.hasSeenOnboarding(), true);
      });
    });

    group('clearAll', () {
      test('should clear all SharedPreferences', () async {
        await OnboardingPreferences.setOnboardingComplete();
        expect(await OnboardingPreferences.hasSeenOnboarding(), true);

        await OnboardingPreferences.clearAll();
        expect(await OnboardingPreferences.hasSeenOnboarding(), false);
      });

      test('should not throw error when clearing empty preferences', () async {
        expect(() => OnboardingPreferences.clearAll(), returnsNormally);
      });
    });

    group('Integration', () {
      test('should handle complete onboarding flow', () async {
        // Initial state
        expect(await OnboardingPreferences.hasSeenOnboarding(), false);

        // Complete onboarding
        await OnboardingPreferences.setOnboardingComplete();
        expect(await OnboardingPreferences.hasSeenOnboarding(), true);

        // Reset
        await OnboardingPreferences.resetOnboarding();
        expect(await OnboardingPreferences.hasSeenOnboarding(), false);

        // Complete again
        await OnboardingPreferences.setOnboardingComplete();
        expect(await OnboardingPreferences.hasSeenOnboarding(), true);

        // Clear all
        await OnboardingPreferences.clearAll();
        expect(await OnboardingPreferences.hasSeenOnboarding(), false);
      });

      test('should handle rapid sequential operations', () async {
        await OnboardingPreferences.setOnboardingComplete();
        await OnboardingPreferences.resetOnboarding();
        await OnboardingPreferences.setOnboardingComplete();
        await OnboardingPreferences.resetOnboarding();

        expect(await OnboardingPreferences.hasSeenOnboarding(), false);
      });
    });
  });

  group('AppConstants', () {
    test('should have correct splash duration', () {
      expect(AppConstants.splashDuration, Duration(seconds: 3));
    });

    test('should have correct splash fade duration', () {
      expect(AppConstants.splashFadeDuration, Duration(milliseconds: 1500));
    });

    test('should have correct onboarding page transition', () {
      expect(
        AppConstants.onboardingPageTransition,
        Duration(milliseconds: 500),
      );
    });

    test('should have correct onboarding page count', () {
      expect(AppConstants.onboardingPageCount, 4);
    });

    group('Colors', () {
      test('should have correct color values', () {
        expect(AppConstants.colorBlue, 0xFF4A90E2);
        expect(AppConstants.colorGreen, 0xFF50C878);
        expect(AppConstants.colorRed, 0xFFFF6B6B);
        expect(AppConstants.colorOrange, 0xFFFFB84D);
      });

      test('color values should be valid hex colors', () {
        // Check if values are within valid ARGB range
        expect(AppConstants.colorBlue, greaterThanOrEqualTo(0x00000000));
        expect(AppConstants.colorBlue, lessThanOrEqualTo(0xFFFFFFFF));

        expect(AppConstants.colorGreen, greaterThanOrEqualTo(0x00000000));
        expect(AppConstants.colorGreen, lessThanOrEqualTo(0xFFFFFFFF));

        expect(AppConstants.colorRed, greaterThanOrEqualTo(0x00000000));
        expect(AppConstants.colorRed, lessThanOrEqualTo(0xFFFFFFFF));

        expect(AppConstants.colorOrange, greaterThanOrEqualTo(0x00000000));
        expect(AppConstants.colorOrange, lessThanOrEqualTo(0xFFFFFFFF));
      });
    });

    group('Asset Paths', () {
      test('should have correct splash image path', () {
        expect(
          AppConstants.splashImagePath,
          'assets/splashScreen/splash-screen.png',
        );
      });

      test('should have correct onboarding image paths', () {
        expect(AppConstants.onboarding1, 'assets/onboarding/onboarding-1.png');
        expect(AppConstants.onboarding2, 'assets/onboarding/onboarding-2.png');
        expect(AppConstants.onboarding3, 'assets/onboarding/onboarding-3.png');
        expect(AppConstants.onboarding4, 'assets/onboarding/onboarding-4.png');
      });

      test('should have valid asset path format', () {
        final paths = [
          AppConstants.splashImagePath,
          AppConstants.onboarding1,
          AppConstants.onboarding2,
          AppConstants.onboarding3,
          AppConstants.onboarding4,
        ];

        for (final path in paths) {
          expect(path.startsWith('assets/'), true);
          expect(path.endsWith('.png'), true);
        }
      });

      test('onboarding paths should be numbered sequentially', () {
        expect(AppConstants.onboarding1.contains('onboarding-1'), true);
        expect(AppConstants.onboarding2.contains('onboarding-2'), true);
        expect(AppConstants.onboarding3.contains('onboarding-3'), true);
        expect(AppConstants.onboarding4.contains('onboarding-4'), true);
      });
    });

    group('Duration Consistency', () {
      test('splash fade should be shorter than total splash duration', () {
        expect(
          AppConstants.splashFadeDuration.inMilliseconds,
          lessThan(AppConstants.splashDuration.inMilliseconds),
        );
      });

      test('all durations should be positive', () {
        expect(AppConstants.splashDuration.inMilliseconds, greaterThan(0));
        expect(AppConstants.splashFadeDuration.inMilliseconds, greaterThan(0));
        expect(
          AppConstants.onboardingPageTransition.inMilliseconds,
          greaterThan(0),
        );
      });
    });
  });
}
