import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/models/leave_request_model.dart';

void main() {
  group('LeaveRequestModel Tests', () {
    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = {
          'id': 1,
          'jenis': 'Cuti Tahunan',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason': 'Liburan keluarga ke Bali',
          'attachment': 'documents/leave_proof.pdf',
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.id, 1);
        expect(leaveRequest.jenis, 'Cuti Tahunan');
        expect(leaveRequest.startDate, '2024-12-15');
        expect(leaveRequest.endDate, '2024-12-17');
        expect(leaveRequest.reason, 'Liburan keluarga ke Bali');
        expect(leaveRequest.attachment, 'documents/leave_proof.pdf');
        expect(leaveRequest.status, 'pending');
      });

      test('should parse JSON without attachment (null)', () {
        // Arrange
        final json = {
          'id': 2,
          'jenis': 'Sakit',
          'start_date': '2024-12-10',
          'end_date': '2024-12-11',
          'reason': 'Demam dan flu',
          'attachment': null,
          'status': 'approved',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.id, 2);
        expect(leaveRequest.jenis, 'Sakit');
        expect(leaveRequest.attachment, isNull);
        expect(leaveRequest.status, 'approved');
      });

      test('should parse JSON with different leave types (jenis)', () {
        // Arrange - Test Izin
        final jsonIzin = {
          'id': 3,
          'jenis': 'Izin',
          'start_date': '2024-12-20',
          'end_date': '2024-12-20',
          'reason': 'Urusan keluarga',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveIzin = LeaveRequest.fromJson(jsonIzin);

        // Assert
        expect(leaveIzin.jenis, 'Izin');
        expect(leaveIzin.startDate, leaveIzin.endDate); // Same day leave
      });

      test('should parse JSON with different status values', () {
        // Test status: pending
        final jsonPending = {
          'id': 4,
          'jenis': 'Cuti',
          'start_date': '2024-12-25',
          'end_date': '2024-12-26',
          'reason': 'Test pending',
          'attachment': null,
          'status': 'pending',
        };

        // Test status: approved
        final jsonApproved = {
          'id': 5,
          'jenis': 'Cuti',
          'start_date': '2024-12-25',
          'end_date': '2024-12-26',
          'reason': 'Test approved',
          'attachment': null,
          'status': 'approved',
        };

        // Test status: rejected
        final jsonRejected = {
          'id': 6,
          'jenis': 'Cuti',
          'start_date': '2024-12-25',
          'end_date': '2024-12-26',
          'reason': 'Test rejected',
          'attachment': null,
          'status': 'rejected',
        };

        // Test status: canceled
        final jsonCanceled = {
          'id': 7,
          'jenis': 'Cuti',
          'start_date': '2024-12-25',
          'end_date': '2024-12-26',
          'reason': 'Test canceled',
          'attachment': null,
          'status': 'canceled',
        };

        // Act
        final leavePending = LeaveRequest.fromJson(jsonPending);
        final leaveApproved = LeaveRequest.fromJson(jsonApproved);
        final leaveRejected = LeaveRequest.fromJson(jsonRejected);
        final leaveCanceled = LeaveRequest.fromJson(jsonCanceled);

        // Assert
        expect(leavePending.status, 'pending');
        expect(leaveApproved.status, 'approved');
        expect(leaveRejected.status, 'rejected');
        expect(leaveCanceled.status, 'canceled');
      });

      test('should handle long reason text', () {
        // Arrange
        final json = {
          'id': 8,
          'jenis': 'Cuti Tahunan',
          'start_date': '2024-12-15',
          'end_date': '2024-12-20',
          'reason':
              'Saya mengajukan cuti tahunan untuk keperluan liburan keluarga. '
              'Kami berencana mengunjungi beberapa tempat wisata di Yogyakarta '
              'dan membutuhkan waktu 5 hari untuk perjalanan dan istirahat. '
              'Semua pekerjaan sudah saya selesaikan dan delegasikan.',
          'attachment': 'documents/long_leave.pdf',
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.reason, isNotEmpty);
        expect(leaveRequest.reason.length, greaterThan(100));
      });

      test('should parse JSON with attachment file path', () {
        // Arrange
        final json = {
          'id': 9,
          'jenis': 'Sakit',
          'start_date': '2024-12-10',
          'end_date': '2024-12-12',
          'reason': 'Sakit demam berdarah',
          'attachment': 'storage/leave_attachments/surat_dokter.jpg',
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.attachment, isNotNull);
        expect(leaveRequest.attachment, contains('surat_dokter.jpg'));
        expect(leaveRequest.attachment, startsWith('storage/'));
      });

      test('should handle empty string attachment', () {
        // Arrange
        final json = {
          'id': 10,
          'jenis': 'Izin',
          'start_date': '2024-12-15',
          'end_date': '2024-12-15',
          'reason': 'Keperluan mendadak',
          'attachment': '', // Empty string
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.attachment, isEmpty);
        expect(leaveRequest.attachment, isNotNull);
      });

      test('should parse date strings in YYYY-MM-DD format', () {
        // Arrange
        final json = {
          'id': 11,
          'jenis': 'Cuti',
          'start_date': '2024-01-01', // New Year
          'end_date': '2024-01-03',
          'reason': 'Liburan tahun baru',
          'attachment': null,
          'status': 'approved',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.startDate, matches(r'^\d{4}-\d{2}-\d{2}$'));
        expect(leaveRequest.endDate, matches(r'^\d{4}-\d{2}-\d{2}$'));
        expect(leaveRequest.startDate, '2024-01-01');
        expect(leaveRequest.endDate, '2024-01-03');
      });

      test('should handle single day leave (start_date equals end_date)', () {
        // Arrange
        final json = {
          'id': 12,
          'jenis': 'Izin',
          'start_date': '2024-12-20',
          'end_date': '2024-12-20', // Same day
          'reason': 'Menghadiri acara keluarga',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.startDate, equals(leaveRequest.endDate));
      });

      test('should parse JSON with numeric id as integer', () {
        // Arrange
        final json = {
          'id': 999, // Large ID
          'jenis': 'Cuti',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason': 'Test large ID',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.id, isA<int>());
        expect(leaveRequest.id, 999);
      });
    });

    group('Object Properties', () {
      test('should have correct property types', () {
        // Arrange
        final json = {
          'id': 1,
          'jenis': 'Cuti',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason': 'Test',
          'attachment': 'test.pdf',
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.id, isA<int>());
        expect(leaveRequest.jenis, isA<String>());
        expect(leaveRequest.startDate, isA<String>());
        expect(leaveRequest.endDate, isA<String>());
        expect(leaveRequest.reason, isA<String>());
        expect(leaveRequest.attachment, isA<String?>());
        expect(leaveRequest.status, isA<String>());
      });

      test('should handle all required fields as non-null', () {
        // Arrange
        final json = {
          'id': 1,
          'jenis': 'Cuti',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason': 'Test',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert - Required fields should not be null
        expect(leaveRequest.id, isNotNull);
        expect(leaveRequest.jenis, isNotNull);
        expect(leaveRequest.startDate, isNotNull);
        expect(leaveRequest.endDate, isNotNull);
        expect(leaveRequest.reason, isNotNull);
        expect(leaveRequest.status, isNotNull);
        // Only attachment can be null
      });

      test('should allow null attachment as optional field', () {
        // Arrange
        final json = {
          'id': 1,
          'jenis': 'Izin',
          'start_date': '2024-12-15',
          'end_date': '2024-12-15',
          'reason': 'Test null attachment',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.attachment, isNull);
      });
    });

    group('Edge Cases', () {
      test('should handle special characters in reason', () {
        // Arrange
        final json = {
          'id': 13,
          'jenis': 'Cuti',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason': 'Test with special chars: !@#\$%^&*()_+-=[]{}|;:\'",.<>?',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.reason, contains('!@#'));
        expect(leaveRequest.reason, isNotEmpty);
      });

      test('should handle unicode characters in jenis and reason', () {
        // Arrange
        final json = {
          'id': 14,
          'jenis': 'Cuti 🏖️',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason': 'Liburan ke pantai 🌊☀️',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.jenis, contains('🏖️'));
        expect(leaveRequest.reason, contains('🌊'));
      });

      test('should handle newlines in reason text', () {
        // Arrange
        final json = {
          'id': 15,
          'jenis': 'Cuti',
          'start_date': '2024-12-15',
          'end_date': '2024-12-17',
          'reason':
              'Alasan cuti:\n1. Liburan keluarga\n2. Acara pernikahan\n3. Istirahat',
          'attachment': null,
          'status': 'pending',
        };

        // Act
        final leaveRequest = LeaveRequest.fromJson(json);

        // Assert
        expect(leaveRequest.reason, contains('\n'));
        expect(leaveRequest.reason, contains('1.'));
      });
    });
  });
}
