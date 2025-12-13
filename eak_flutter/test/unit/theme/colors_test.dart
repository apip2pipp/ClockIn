import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/theme/colors.dart';

void main() {
  group('Color Theme Tests', () {
    group('Primary Color', () {
      test('should have correct primary blue color value', () {
        // Assert
        expect(kPrimaryBlue.value, 0xFF26667F);
      });

      test('should have correct RGB values for primary blue', () {
        // Assert
        expect(kPrimaryBlue.red, 38);
        expect(kPrimaryBlue.green, 102);
        expect(kPrimaryBlue.blue, 127);
        expect(kPrimaryBlue.alpha, 255);
      });

      test('should have full opacity', () {
        // Assert
        expect(kPrimaryBlue.opacity, 1.0);
      });
    });

    group('Text Colors', () {
      test('should have correct dark text color value', () {
        // Assert
        expect(kTextDark.value, 0xFF2D3748);
      });

      test('should have correct light text color value', () {
        // Assert
        expect(kTextLight.value, 0xFF718096);
      });

      test('should have different text colors for contrast', () {
        // Assert
        expect(kTextDark.value, isNot(equals(kTextLight.value)));
        // Dark should be darker than light
        expect(
          kTextDark.computeLuminance() < kTextLight.computeLuminance(),
          isTrue,
        );
      });
    });

    group('Background Color', () {
      test('should have correct background light color value', () {
        // Assert
        expect(kBackgroundLight.value, 0xFFF7FAFC);
      });

      test('should have light background for better contrast', () {
        // Assert - background should be very light (high luminance)
        expect(kBackgroundLight.computeLuminance() > 0.9, isTrue);
      });
    });

    group('Color Accessibility', () {
      test(
        'should have sufficient contrast between primary and background',
        () {
          // Assert - primary blue should be dark enough for light background
          final primaryLuminance = kPrimaryBlue.computeLuminance();
          final backgroundLuminance = kBackgroundLight.computeLuminance();

          // Background should be lighter than primary
          expect(backgroundLuminance > primaryLuminance, isTrue);
        },
      );

      test(
        'should have sufficient contrast between text dark and background',
        () {
          // Assert
          final textDarkLuminance = kTextDark.computeLuminance();
          final backgroundLuminance = kBackgroundLight.computeLuminance();

          // Background should be lighter than dark text
          expect(backgroundLuminance > textDarkLuminance, isTrue);
        },
      );
    });

    group('Color Consistency', () {
      test('all colors should have full alpha channel', () {
        // Assert
        expect(kPrimaryBlue.alpha, 255);
        expect(kTextDark.alpha, 255);
        expect(kTextLight.alpha, 255);
        expect(kBackgroundLight.alpha, 255);
      });

      test('all colors should be opaque', () {
        // Assert
        expect(kPrimaryBlue.opacity, 1.0);
        expect(kTextDark.opacity, 1.0);
        expect(kTextLight.opacity, 1.0);
        expect(kBackgroundLight.opacity, 1.0);
      });
    });
  });
}
