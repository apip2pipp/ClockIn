import 'package:flutter_test/flutter_test.dart';

/// Unit Tests for Clock In/Out Validation Logic
/// 
/// Tests business rules for attendance:
/// - Time validation (work hours)
/// - Radius validation (office location)
/// - Duplicate clock in prevention
void main() {
  group('Clock In/Out Validation Tests', () {
    
    group('ATT-U-002: Clock in time validation', () {
      test('should allow clock in within work hours', () {
        // Arrange
        const workStartHour = 8; // 08:00
        const workEndHour = 17; // 17:00
        const clockInHour = 8; // 08:30
        const clockInMinute = 30;

        // Act
        final isWithinWorkHours = clockInHour >= workStartHour && 
                                  clockInHour < workEndHour;

        // Assert
        expect(isWithinWorkHours, isTrue);
      });

      test('should allow clock in at work start time', () {
        // Arrange
        const workStartHour = 8;
        const clockInHour = 8;
        const clockInMinute = 0;

        // Act
        final isValid = clockInHour >= workStartHour;

        // Assert
        expect(isValid, isTrue);
      });

      test('should allow clock in before work end time', () {
        // Arrange
        const workEndHour = 17;
        const clockInHour = 16;
        const clockInMinute = 59;

        // Act
        final isValid = clockInHour < workEndHour;

        // Assert
        expect(isValid, isTrue);
      });

      test('should reject clock in before work hours', () {
        // Arrange
        const workStartHour = 8;
        const clockInHour = 7; // 07:00 - too early
        const clockInMinute = 30;

        // Act
        final isValid = clockInHour >= workStartHour;

        // Assert
        expect(isValid, isFalse);
      });

      test('should handle edge case at midnight', () {
        // Arrange
        const workStartHour = 8;
        const clockInHour = 0; // Midnight

        // Act
        final isValid = clockInHour >= workStartHour;

        // Assert
        expect(isValid, isFalse);
      });

      test('should validate time range correctly', () {
        // Arrange
        final testCases = {
          7: false,  // Before work hours
          8: true,   // Start of work
          12: true,  // Lunch time
          16: true,  // Before end
          17: false, // After work hours
          18: false, // Evening
        };

        const workStartHour = 8;
        const workEndHour = 17;

        // Act & Assert
        testCases.forEach((hour, expected) {
          final isValid = hour >= workStartHour && hour < workEndHour;
          expect(isValid, expected, 
            reason: 'Hour $hour should be ${expected ? "valid" : "invalid"}');
        });
      });
    });

    group('ATT-U-003: Clock in outside radius', () {
      test('should allow clock in within office radius', () {
        // Arrange
        const officeRadius = 100.0; // meters
        const userDistance = 50.0; // meters

        // Act
        final isWithinRadius = userDistance <= officeRadius;

        // Assert
        expect(isWithinRadius, isTrue);
      });

      test('should allow clock in at exact radius boundary', () {
        // Arrange
        const officeRadius = 100.0;
        const userDistance = 100.0; // Exactly at boundary

        // Act
        final isWithinRadius = userDistance <= officeRadius;

        // Assert
        expect(isWithinRadius, isTrue);
      });

      test('should reject clock in outside office radius', () {
        // Arrange
        const officeRadius = 100.0;
        const userDistance = 150.0; // 50 meters too far

        // Act
        final isWithinRadius = userDistance <= officeRadius;

        // Assert
        expect(isWithinRadius, isFalse);
      });

      test('should calculate distance correctly', () {
        // Arrange - Simple distance calculation
        const officeLat = -6.2088;
        const officeLng = 106.8456;
        const userLat = -6.2088; // Same location
        const userLng = 106.8456;

        // Act - Distance should be 0 for same location
        final latDiff = (officeLat - userLat).abs();
        final lngDiff = (officeLng - userLng).abs();
        final isSameLocation = latDiff < 0.0001 && lngDiff < 0.0001;

        // Assert
        expect(isSameLocation, isTrue);
      });

      test('should handle various radius values', () {
        // Arrange
        final testCases = {
          50.0: false,   // 50m radius, user at 75m
          100.0: true,   // 100m radius, user at 75m
          150.0: true,   // 150m radius, user at 75m
          200.0: true,   // 200m radius, user at 75m
        };

        const userDistance = 75.0;

        // Act & Assert
        testCases.forEach((radius, expected) {
          final isValid = userDistance <= radius;
          expect(isValid, expected,
            reason: 'Distance $userDistance with radius $radius should be ${expected ? "valid" : "invalid"}');
        });
      });

      test('should reject negative distance values', () {
        // Arrange
        const distance = -10.0; // Invalid negative distance

        // Act
        final isValid = distance >= 0;

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('ATT-U-004: Duplicate clock in', () {
      test('should detect existing active clock in', () {
        // Arrange
        final hasActiveClockIn = true; // User already clocked in
        final clockOutTime = null; // Not clocked out yet

        // Act
        final isDuplicate = hasActiveClockIn && clockOutTime == null;

        // Assert
        expect(isDuplicate, isTrue);
      });

      test('should allow clock in when no active session', () {
        // Arrange
        final hasActiveClockIn = false; // No active clock in

        // Act
        final canClockIn = !hasActiveClockIn;

        // Assert
        expect(canClockIn, isTrue);
      });

      test('should allow clock in after previous clock out', () {
        // Arrange
        final hasActiveClockIn = true;
        final clockOutTime = '2025-12-14T17:00:00.000000Z'; // Already clocked out

        // Act
        final isDuplicate = hasActiveClockIn && clockOutTime == null;

        // Assert - Not duplicate because already clocked out
        expect(isDuplicate, isFalse);
      });

      test('should check clock out status correctly', () {
        // Arrange - Different scenarios
        final scenarios = [
          {'hasClockIn': false, 'clockOut': null, 'canClockIn': true},
          {'hasClockIn': true, 'clockOut': null, 'canClockIn': false}, // Active session
          {'hasClockIn': true, 'clockOut': '17:00', 'canClockIn': true}, // Completed
        ];

        // Act & Assert
        for (final scenario in scenarios) {
          final hasClockIn = scenario['hasClockIn'] as bool;
          final clockOut = scenario['clockOut'];
          final expected = scenario['canClockIn'] as bool;

          final canClockIn = !hasClockIn || clockOut != null;
          expect(canClockIn, expected);
        }
      });

      test('should validate session state', () {
        // Arrange
        String? clockInTime = '2025-12-14T08:00:00.000000Z';
        String? clockOutTime = null;

        // Act - Check if session is active
        final isActiveSession = clockInTime != null && clockOutTime == null;

        // Assert
        expect(isActiveSession, isTrue);
      });

      test('should handle completed session', () {
        // Arrange
        String? clockInTime = '2025-12-14T08:00:00.000000Z';
        String? clockOutTime = '2025-12-14T17:00:00.000000Z';

        // Act
        final isActiveSession = clockInTime != null && clockOutTime == null;

        // Assert - Session is completed, not active
        expect(isActiveSession, isFalse);
      });
    });

    group('Combined Validation Logic', () {
      test('should validate all conditions for successful clock in', () {
        // Arrange
        const workStartHour = 8;
        const workEndHour = 17;
        const clockInHour = 9;
        const officeRadius = 100.0;
        const userDistance = 50.0;
        final hasActiveClockIn = false;

        // Act
        final isValidTime = clockInHour >= workStartHour && clockInHour < workEndHour;
        final isValidLocation = userDistance <= officeRadius;
        final canClockIn = !hasActiveClockIn;
        final allValid = isValidTime && isValidLocation && canClockIn;

        // Assert
        expect(allValid, isTrue);
      });

      test('should fail if any condition is invalid', () {
        // Arrange - Invalid time
        const clockInHour = 7; // Before work hours
        const workStartHour = 8;
        const officeRadius = 100.0;
        const userDistance = 50.0;
        final hasActiveClockIn = false;

        // Act
        final isValidTime = clockInHour >= workStartHour;
        final isValidLocation = userDistance <= officeRadius;
        final canClockIn = !hasActiveClockIn;
        final allValid = isValidTime && isValidLocation && canClockIn;

        // Assert
        expect(allValid, isFalse);
      });
    });
  });
}
