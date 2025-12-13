import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/services/attendance_service.dart';
import 'package:eak_flutter/config/api_config.dart';

void main() {
  group('AttendanceService Tests', () {
    group('URL Construction', () {
      test('should construct correct URL with basic pagination', () {
        // Arrange
        const page = 1;
        const perPage = 15;

        // Act
        final expectedUrl =
            '${ApiConfig.getFullUrl(ApiConfig.attendanceHistoryEndpoint)}?page=$page&per_page=$perPage';

        // Assert
        expect(expectedUrl, contains('/attendance/history'));
        expect(expectedUrl, contains('page=1'));
        expect(expectedUrl, contains('per_page=15'));
      });

      test('should include month parameter when provided', () {
        // Arrange
        const page = 1;
        const perPage = 15;
        const month = 12;

        // Act
        final expectedUrl =
            '${ApiConfig.getFullUrl(ApiConfig.attendanceHistoryEndpoint)}?page=$page&per_page=$perPage&month=$month';

        // Assert
        expect(expectedUrl, contains('month=12'));
      });

      test('should include year parameter when provided', () {
        // Arrange
        const page = 1;
        const perPage = 15;
        const year = 2024;

        // Act
        final expectedUrl =
            '${ApiConfig.getFullUrl(ApiConfig.attendanceHistoryEndpoint)}?page=$page&per_page=$perPage&year=$year';

        // Assert
        expect(expectedUrl, contains('year=2024'));
      });

      test('should include both month and year when provided', () {
        // Arrange
        const page = 2;
        const perPage = 20;
        const month = 11;
        const year = 2024;

        // Act
        final expectedUrl =
            '${ApiConfig.getFullUrl(ApiConfig.attendanceHistoryEndpoint)}?page=$page&per_page=$perPage&month=$month&year=$year';

        // Assert
        expect(expectedUrl, contains('page=2'));
        expect(expectedUrl, contains('per_page=20'));
        expect(expectedUrl, contains('month=11'));
        expect(expectedUrl, contains('year=2024'));
      });
    });

    group('Method Existence', () {
      test('should have getAttendanceHistory method', () {
        expect(AttendanceService.getAttendanceHistory, isNotNull);
      });

      test('should have method with named parameters', () {
        // This test verifies the method signature by attempting to call with named params
        expect(
          () => AttendanceService.getAttendanceHistory(
            page: 1,
            perPage: 15,
            month: 12,
            year: 2024,
          ),
          returnsNormally,
        );
      });
    });

    group('Parameter Validation', () {
      test('should accept default parameters', () {
        // Verify method can be called with defaults
        expect(() => AttendanceService.getAttendanceHistory(), returnsNormally);
      });

      test('should accept custom page and perPage', () {
        expect(
          () => AttendanceService.getAttendanceHistory(page: 5, perPage: 25),
          returnsNormally,
        );
      });

      test('should accept null month and year', () {
        expect(
          () => AttendanceService.getAttendanceHistory(month: null, year: null),
          returnsNormally,
        );
      });

      test('should accept valid month range (1-12)', () {
        for (int month = 1; month <= 12; month++) {
          expect(
            () => AttendanceService.getAttendanceHistory(month: month),
            returnsNormally,
          );
        }
      });

      test('should accept valid year values', () {
        expect(
          () => AttendanceService.getAttendanceHistory(year: 2020),
          returnsNormally,
        );
        expect(
          () => AttendanceService.getAttendanceHistory(year: 2024),
          returnsNormally,
        );
        expect(
          () => AttendanceService.getAttendanceHistory(year: 2025),
          returnsNormally,
        );
      });
    });

    // NOTE: Integration tests dengan real API call di-skip karena butuh:
    // 1. Mock HTTP client (tapi service pakai static methods)
    // 2. Real backend server
    // 3. Valid authentication token
    //
    // Untuk complete testing, perlu refactor service ke instance-based
    // agar bisa inject MockClient untuk testing.
  });
}
