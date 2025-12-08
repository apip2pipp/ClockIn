import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/providers/attendance_provider.dart';
import 'package:eak_flutter/models/attendance_model.dart';

void main() {
  group('AttendanceProvider', () {
    group('Initialization', () {
      test('should initialize with default values', () {
        final provider = AttendanceProvider();

        expect(provider.todayAttendance, isNull);
        expect(provider.attendanceHistory, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);

        provider.dispose();
      });

      test('should have empty attendance history initially', () {
        final provider = AttendanceProvider();

        expect(provider.attendanceHistory, isEmpty);
        expect(provider.isLoading, isFalse);
        expect(provider.errorMessage, isNull);

        provider.dispose();
      });
    });

    group('State Management', () {
      test('should have correct isLoading initial state', () {
        final provider = AttendanceProvider();

        expect(provider.isLoading, isFalse);

        provider.dispose();
      });

      test('should have null error message initially', () {
        final provider = AttendanceProvider();

        expect(provider.errorMessage, isNull);

        provider.dispose();
      });
    });

    group('Getters', () {
      test('todayAttendance getter should return null initially', () {
        final provider = AttendanceProvider();

        expect(provider.todayAttendance, isNull);
        expect(provider.todayAttendance, isNull); // Call twice for consistency

        provider.dispose();
      });

      test('attendanceHistory getter should return empty list', () {
        final provider = AttendanceProvider();

        expect(provider.attendanceHistory, isEmpty);
        expect(provider.attendanceHistory, isA<List<Attendance>>());

        provider.dispose();
      });

      test('attendanceHistory should be a list type', () {
        final provider = AttendanceProvider();

        expect(provider.attendanceHistory, isA<List<Attendance>>());

        provider.dispose();
      });

      test('errorMessage getter should handle null correctly', () {
        final provider = AttendanceProvider();

        expect(provider.errorMessage, isNull);

        provider.dispose();
      });

      test('errorMessage should be nullable string', () {
        final provider = AttendanceProvider();

        expect(provider.errorMessage, isA<String?>());

        provider.dispose();
      });
    });

    group('Null Safety', () {
      test('should handle null todayAttendance safely', () {
        final provider = AttendanceProvider();

        expect(provider.todayAttendance, isNull);
        final attendance = provider.todayAttendance;
        expect(attendance, isNull);

        provider.dispose();
      });

      test('should handle empty attendance history', () {
        final provider = AttendanceProvider();

        final history = provider.attendanceHistory;
        expect(history.isEmpty, isTrue);
        expect(history.length, 0);

        provider.dispose();
      });

      test('should handle multiple access to loading state', () {
        final provider = AttendanceProvider();

        final loading = provider.isLoading;
        expect(loading, isFalse);
        expect(provider.isLoading, isFalse);

        provider.dispose();
      });

      test('should handle null error message gracefully', () {
        final provider = AttendanceProvider();

        final error = provider.errorMessage;
        expect(error, isNull);

        provider.dispose();
      });
    });

    group('Lifecycle', () {
      test('should be able to dispose provider', () {
        final provider = AttendanceProvider();

        expect(() => provider.dispose(), returnsNormally);
      });

      test('should be able to create multiple instances', () {
        final provider1 = AttendanceProvider();
        final provider2 = AttendanceProvider();

        expect(provider1, isNot(same(provider2)));
        expect(provider1.todayAttendance, isNull);
        expect(provider2.todayAttendance, isNull);

        provider1.dispose();
        provider2.dispose();
      });
    });
  });
}
