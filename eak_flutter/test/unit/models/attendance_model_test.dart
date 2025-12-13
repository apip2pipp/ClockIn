import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/models/attendance_model.dart';

void main() {
  group('AttendanceModel Tests', () {
    group('fromJson', () {
      test('should parse complete attendance JSON correctly', () {
        // Arrange
        final json = {
          'id': 1,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T08:00:00Z',
          'clock_out': '2025-12-07T17:00:00Z',
          'clock_in_notes': 'On time',
          'clock_out_notes': 'Work done',
          'clock_in_latitude': -6.2088,
          'clock_in_longitude': 106.8456,
          'clock_out_latitude': -6.2090,
          'clock_out_longitude': 106.8458,
          'clock_in_photo': 'photos/clockin.jpg',
          'clock_out_photo': 'photos/clockout.jpg',
          'work_duration': 540, // 9 hours in minutes
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(json);

        // Assert
        expect(attendance.id, 1);
        expect(attendance.userId, 10);
        expect(attendance.companyId, 5);
        expect(attendance.clockIn, isA<DateTime>());
        expect(attendance.clockOut, isA<DateTime>());
        expect(attendance.clockInNotes, 'On time');
        expect(attendance.clockOutNotes, 'Work done');
        expect(attendance.clockInLatitude, -6.2088);
        expect(attendance.clockInLongitude, 106.8456);
        expect(attendance.clockOutLatitude, -6.2090);
        expect(attendance.clockOutLongitude, 106.8458);
        expect(attendance.clockInPhoto, isNotNull);
        expect(attendance.clockOutPhoto, isNotNull);
        expect(attendance.workDuration, 540);
        expect(attendance.status, 'on_time');
      });

      test('should parse attendance without clock out', () {
        // Arrange
        final json = {
          'id': 2,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T08:00:00Z',
          'clock_out': null,
          'clock_in_latitude': -6.2088,
          'clock_in_longitude': 106.8456,
          'clock_in_photo': 'photos/clockin.jpg',
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(json);

        // Assert
        expect(attendance.id, 2);
        expect(attendance.clockIn, isA<DateTime>());
        expect(attendance.clockOut, isNull);
        expect(attendance.clockOutNotes, isNull);
        expect(attendance.clockOutLatitude, isNull);
        expect(attendance.clockOutLongitude, isNull);
        expect(attendance.clockOutPhoto, isNull);
        expect(attendance.workDuration, isNull);
      });

      test('should handle latitude/longitude as String', () {
        // Arrange
        final json = {
          'id': 3,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T08:00:00Z',
          'clock_in_latitude': '-6.2088', // String
          'clock_in_longitude': '106.8456', // String
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(json);

        // Assert
        expect(attendance.clockInLatitude, -6.2088);
        expect(attendance.clockInLongitude, 106.8456);
      });

      test('should handle latitude/longitude as int', () {
        // Arrange
        final json = {
          'id': 4,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T08:00:00Z',
          'clock_in_latitude': -6, // int
          'clock_in_longitude': 106, // int
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(json);

        // Assert
        expect(attendance.clockInLatitude, -6.0);
        expect(attendance.clockInLongitude, 106.0);
      });

      test('should handle default status when not provided', () {
        // Arrange
        final json = {
          'id': 5,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T08:00:00Z',
          // status not provided
        };

        // Act
        final attendance = Attendance.fromJson(json);

        // Assert
        expect(attendance.status, 'on_time'); // default value
      });

      test('should handle different status values', () {
        // Arrange - late
        final jsonLate = {
          'id': 6,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T09:00:00Z',
          'status': 'late',
        };

        // Act
        final attendanceLate = Attendance.fromJson(jsonLate);

        // Assert
        expect(attendanceLate.status, 'late');
      });
    });

    group('toJson', () {
      test('should convert Attendance to JSON correctly', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime.parse('2025-12-07T08:00:00Z'),
          clockOut: DateTime.parse('2025-12-07T17:00:00Z'),
          clockInNotes: 'On time',
          clockOutNotes: 'Done',
          clockInLatitude: -6.2088,
          clockInLongitude: 106.8456,
          clockOutLatitude: -6.2090,
          clockOutLongitude: 106.8458,
          clockInPhoto: 'photos/in.jpg',
          clockOutPhoto: 'photos/out.jpg',
          workDuration: 540,
          status: 'on_time',
        );

        // Act
        final json = attendance.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['user_id'], 10);
        expect(json['company_id'], 5);
        expect(json['clock_in'], isA<String>());
        expect(json['clock_out'], isA<String>());
        expect(json['clock_in_notes'], 'On time');
        expect(json['clock_out_notes'], 'Done');
        expect(json['clock_in_latitude'], -6.2088);
        expect(json['clock_in_longitude'], 106.8456);
        expect(json['status'], 'on_time');
      });

      test('should handle null values in toJson', () {
        // Arrange
        final attendance = Attendance(
          id: 2,
          userId: 10,
          companyId: 5,
          clockIn: DateTime.parse('2025-12-07T08:00:00Z'),
          status: 'on_time',
        );

        // Act
        final json = attendance.toJson();

        // Assert
        expect(json['clock_out'], isNull);
        expect(json['clock_in_notes'], isNull);
        expect(json['clock_out_notes'], isNull);
        expect(json['work_duration'], isNull);
      });
    });

    group('Getters', () {
      test('clockInTime should return formatted time', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 8, 30), // 08:30
          status: 'on_time',
        );

        // Act
        final time = attendance.clockInTime;

        // Assert
        expect(time, '08:30');
      });

      test('clockInTime should pad single digits', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 9, 5), // 09:05
          status: 'on_time',
        );

        // Act
        final time = attendance.clockInTime;

        // Assert
        expect(time, '09:05');
      });

      test(
        'clockOutTime should return formatted time when clockOut exists',
        () {
          // Arrange
          final attendance = Attendance(
            id: 1,
            userId: 10,
            companyId: 5,
            clockIn: DateTime(2025, 12, 7, 8, 0),
            clockOut: DateTime(2025, 12, 7, 17, 30), // 17:30
            status: 'on_time',
          );

          // Act
          final time = attendance.clockOutTime;

          // Assert
          expect(time, '17:30');
        },
      );

      test('clockOutTime should return dash when clockOut is null', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 8, 0),
          status: 'on_time',
        );

        // Act
        final time = attendance.clockOutTime;

        // Assert
        expect(time, '-');
      });

      test(
        'formattedWorkDuration should format hours and minutes correctly',
        () {
          // Arrange
          final attendance = Attendance(
            id: 1,
            userId: 10,
            companyId: 5,
            clockIn: DateTime(2025, 12, 7, 8, 0),
            workDuration: 540, // 9 hours * 60 minutes = 540 minutes
            status: 'on_time',
          );

          // Act
          final duration = attendance.formattedWorkDuration;

          // Assert
          expect(duration, '9h 0m');
        },
      );

      test('formattedWorkDuration should handle hours and minutes', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 8, 0),
          workDuration: 545, // 9 hours 5 minutes
          status: 'on_time',
        );

        // Act
        final duration = attendance.formattedWorkDuration;

        // Assert
        expect(duration, '9h 5m');
      });

      test('formattedWorkDuration should return dash when null', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 8, 0),
          workDuration: null,
          status: 'on_time',
        );

        // Act
        final duration = attendance.formattedWorkDuration;

        // Assert
        expect(duration, '-');
      });
    });

    group('Edge Cases', () {
      test('should handle zero work duration', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 8, 0),
          workDuration: 0,
          status: 'on_time',
        );

        // Act
        final duration = attendance.formattedWorkDuration;

        // Assert
        expect(duration, '0h 0m');
      });

      test('should handle very long work duration', () {
        // Arrange
        final attendance = Attendance(
          id: 1,
          userId: 10,
          companyId: 5,
          clockIn: DateTime(2025, 12, 7, 8, 0),
          workDuration: 1440, // 24 hours
          status: 'on_time',
        );

        // Act
        final duration = attendance.formattedWorkDuration;

        // Assert
        expect(duration, '24h 0m');
      });

      test('should handle invalid latitude/longitude strings', () {
        // Arrange
        final json = {
          'id': 1,
          'user_id': 10,
          'company_id': 5,
          'clock_in': '2025-12-07T08:00:00Z',
          'clock_in_latitude': 'invalid',
          'clock_in_longitude': 'invalid',
          'status': 'on_time',
        };

        // Act
        final attendance = Attendance.fromJson(json);

        // Assert
        expect(attendance.clockInLatitude, isNull);
        expect(attendance.clockInLongitude, isNull);
      });
    });
  });
}
