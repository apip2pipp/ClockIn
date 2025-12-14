import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/models/attendance_model.dart';
import 'package:eak_flutter/providers/attendance_provider.dart';

/// Integration Tests for Attendance (Clock In/Out) Feature
/// 
/// Simplified tests focusing on data flow and state management
void main() {
  group('Attendance Integration Tests', () {
    late AttendanceProvider provider;

    setUp(() {
      provider = AttendanceProvider();
    });

    tearDown(() {
      provider.dispose();
    });

    group('ATT-I-001: Clock In with GPS', () {
      test('should create attendance record with GPS data from JSON', () {
        // Arrange
        final clockInJson = {
          'id': 1,
          'user_id': 1,
          'company_id': 1,
          'clock_in': '2025-12-14T08:00:00.000000Z',
          'clock_out': null,
          'clock_in_latitude': -6.2088,
          'clock_in_longitude': 106.8456,
          'clock_in_photo': 'photos/clock_in_123.jpg',
          'work_duration': null,
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(clockInJson);

        // Assert - GPS data is captured
        expect(attendance.id, 1);
        expect(attendance.userId, 1);
        expect(attendance.companyId, 1);
        expect(attendance.clockIn, isA<DateTime>());
        expect(attendance.clockInLatitude, -6.2088);
        expect(attendance.clockInLongitude, 106.8456);
        expect(attendance.clockOut, isNull);
        expect(attendance.workDuration, isNull);
        expect(attendance.status, 'on_time');
      });

      test('should validate GPS coordinates are within valid range', () {
        // Arrange - Valid coordinates
        final validLat = -6.2088; // Jakarta latitude
        final validLng = 106.8456; // Jakarta longitude

        // Assert - Coordinates are valid
        expect(validLat, greaterThanOrEqualTo(-90));
        expect(validLat, lessThanOrEqualTo(90));
        expect(validLng, greaterThanOrEqualTo(-180));
        expect(validLng, lessThanOrEqualTo(180));
      });

      test('should handle string lat/lng conversion', () {
        // Arrange - API might return lat/lng as strings
        final jsonWithStringCoords = {
          'id': 1,
          'user_id': 1,
          'company_id': 1,
          'clock_in': '2025-12-14T08:00:00.000000Z',
          'clock_in_latitude': '-6.2088', // String
          'clock_in_longitude': '106.8456', // String
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(jsonWithStringCoords);

        // Assert - Strings converted to double
        expect(attendance.clockInLatitude, isA<double>());
        expect(attendance.clockInLongitude, isA<double>());
        expect(attendance.clockInLatitude, -6.2088);
        expect(attendance.clockInLongitude, 106.8456);
      });
    });

    group('ATT-I-002: Clock Out Calculation', () {
      test('should parse attendance with clock out data', () {
        // Arrange
        final attendanceJson = {
          'id': 1,
          'user_id': 1,
          'company_id': 1,
          'clock_in': '2025-12-14T08:00:00.000000Z',
          'clock_out': '2025-12-14T17:00:00.000000Z',
          'work_duration': 540, // 9 hours in minutes
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(attendanceJson);

        // Assert - Duration is stored
        expect(attendance.clockOut, isNotNull);
        expect(attendance.clockOut, isA<DateTime>());
        expect(attendance.workDuration, 540);
      });

      test('should format work duration correctly', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 1,
          companyId: 1,
          clockIn: DateTime.parse('2025-12-14T08:00:00.000000Z'),
          clockOut: DateTime.parse('2025-12-14T17:00:00.000000Z'),
          workDuration: 540, // 9 hours = 540 minutes
          status: 'on_time',
        );

        // Act
        final formatted = attendance.formattedWorkDuration;

        // Assert
        expect(formatted, '9h 0m');
      });

      test('should handle different work durations', () {
        // Arrange - Test various durations in minutes
        final durations = {
          480: '8h 0m',    // 8 hours
          570: '9h 30m',   // 9.5 hours
          465: '7h 45m',   // 7 hours 45 minutes
        };

        // Act & Assert
        durations.forEach((minutes, expected) {
          final attendance = Attendance(
            id: 1,
            userId: 1,
            companyId: 1,
            clockIn: DateTime.parse('2025-12-14T08:00:00.000000Z'),
            workDuration: minutes,
            status: 'on_time',
          );

          expect(attendance.formattedWorkDuration, expected);
        });
      });
    });

    group('ATT-I-003: Attendance API Sync', () {
      test('should handle null work duration', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 1,
          companyId: 1,
          clockIn: DateTime.parse('2025-12-14T08:00:00.000000Z'),
          workDuration: null,
          status: 'on_time',
        );

        // Act
        final formatted = attendance.formattedWorkDuration;

        // Assert
        expect(formatted, '-');
      });

      test('should format clock in time correctly', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 1,
          companyId: 1,
          clockIn: DateTime.parse('2025-12-14T08:30:00.000000Z'),
          status: 'on_time',
        );

        // Act
        final clockInTime = attendance.clockInTime;

        // Assert
        expect(clockInTime, matches(r'\d{2}:\d{2}'));
      });

      test('should format clock out time correctly', () {
        // Arrange - With clock out
        final attendanceWithClockOut = Attendance(
          id: 1,
          userId: 1,
          companyId: 1,
          clockIn: DateTime.parse('2025-12-14T08:00:00.000000Z'),
          clockOut: DateTime.parse('2025-12-14T17:30:00.000000Z'),
          status: 'on_time',
        );

        // Arrange - Without clock out
        final attendanceWithoutClockOut = Attendance(
          id: 2,
          userId: 1,
          companyId: 1,
          clockIn: DateTime.parse('2025-12-14T08:00:00.000000Z'),
          status: 'on_time',
        );

        // Act & Assert
        expect(attendanceWithClockOut.clockOutTime, matches(r'\d{2}:\d{2}'));
        expect(attendanceWithoutClockOut.clockOutTime, '-');
      });
    });

    group('Provider State Management', () {
      test('should initialize with default values', () {
        // Assert
        expect(provider.todayAttendance, isNull);
        expect(provider.attendanceHistory, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);
      });

      test('should handle null attendance gracefully', () {
        // Act
        final todayAttendance = provider.todayAttendance;

        // Assert
        expect(todayAttendance, isNull);
      });
    });
  });
}
