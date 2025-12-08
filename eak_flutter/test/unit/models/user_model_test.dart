import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/models/user_model.dart';

void main() {
  group('UserModel Tests', () {
    group('fromJson', () {
      test('should parse complete JSON correctly', () {
        // Arrange
        final json = {
          'id': 1,
          'company_id': 10,
          'name': 'John Doe',
          'email': 'john@example.com',
          'phone': '081234567890',
          'position': 'Software Engineer',
          'employee_id': 'EMP001',
          'photo': 'photos/user.jpg',
          'role': 'employee',
          'is_active': 1,
          'company': {
            'id': 10,
            'name': 'PT Tech Indonesia',
            'email': 'info@tech.com',
            'phone': '021123456',
            'address': 'Jakarta',
            'latitude': -6.2088,
            'longitude': 106.8456,
            'radius': 100,
            'work_start_time': '08:00',
            'work_end_time': '17:00',
            'is_active': 1,
            'logo': 'logos/company.png',
          },
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, 1);
        expect(user.companyId, 10);
        expect(user.name, 'John Doe');
        expect(user.email, 'john@example.com');
        expect(user.phone, '081234567890');
        expect(user.position, 'Software Engineer');
        expect(user.employeeId, 'EMP001');
        expect(user.photo, 'photos/user.jpg');
        expect(user.role, 'employee');
        expect(user.isActive, true);
        expect(user.company, isNotNull);
        expect(user.company!.name, 'PT Tech Indonesia');
      });

      test('should parse JSON with minimal fields', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'Jane Doe',
          'email': 'jane@example.com',
          'role': 'admin',
          'is_active': true,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.id, 2);
        expect(user.name, 'Jane Doe');
        expect(user.email, 'jane@example.com');
        expect(user.role, 'admin');
        expect(user.isActive, true);
        expect(user.companyId, isNull);
        expect(user.phone, isNull);
        expect(user.position, isNull);
        expect(user.employeeId, isNull);
        expect(user.photo, isNull);
        expect(user.company, isNull);
      });

      test('should handle is_active as boolean', () {
        // Arrange
        final json = {
          'id': 3,
          'name': 'Test User',
          'email': 'test@example.com',
          'role': 'employee',
          'is_active': true, // boolean
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.isActive, true);
      });

      test('should handle is_active as integer 1', () {
        // Arrange
        final json = {
          'id': 4,
          'name': 'Test User',
          'email': 'test@example.com',
          'role': 'employee',
          'is_active': 1, // integer
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.isActive, true);
      });

      test('should handle is_active as integer 0', () {
        // Arrange
        final json = {
          'id': 5,
          'name': 'Inactive User',
          'email': 'inactive@example.com',
          'role': 'employee',
          'is_active': 0, // integer 0 = false
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.isActive, false);
      });

      test('should parse company data when present', () {
        // Arrange
        final json = {
          'id': 6,
          'name': 'User with Company',
          'email': 'user@example.com',
          'role': 'employee',
          'is_active': 1,
          'company': {
            'id': 20,
            'name': 'Test Company',
            'email': 'company@test.com',
            'radius': 50,
            'work_start_time': '09:00',
            'work_end_time': '18:00',
            'is_active': 1,
          },
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.company, isNotNull);
        expect(user.company!.id, 20);
        expect(user.company!.name, 'Test Company');
        expect(user.company!.email, 'company@test.com');
        expect(user.company!.radius, 50);
        expect(user.company!.workStartTime, '09:00');
        expect(user.company!.workEndTime, '18:00');
      });
    });

    group('toJson', () {
      test('should convert User to JSON correctly', () {
        // Arrange
        final user = User(
          id: 1,
          companyId: 10,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '081234567890',
          position: 'Developer',
          employeeId: 'EMP001',
          photo: 'photos/user.jpg',
          role: 'employee',
          isActive: true,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['company_id'], 10);
        expect(json['name'], 'John Doe');
        expect(json['email'], 'john@example.com');
        expect(json['phone'], '081234567890');
        expect(json['position'], 'Developer');
        expect(json['employee_id'], 'EMP001');
        expect(json['photo'], 'photos/user.jpg');
        expect(json['role'], 'employee');
        expect(json['is_active'], true);
      });

      test('should convert User with null fields to JSON', () {
        // Arrange
        final user = User(
          id: 2,
          name: 'Jane Doe',
          email: 'jane@example.com',
          role: 'admin',
          isActive: false,
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], 2);
        expect(json['name'], 'Jane Doe');
        expect(json['email'], 'jane@example.com');
        expect(json['role'], 'admin');
        expect(json['is_active'], false);
        expect(json['company_id'], isNull);
        expect(json['phone'], isNull);
        expect(json['position'], isNull);
        expect(json['employee_id'], isNull);
        expect(json['photo'], isNull);
      });
    });

    group('photoUrl getter', () {
      test('should return correct photo URL when photo is not null', () {
        // Arrange
        final user = User(
          id: 1,
          name: 'Test User',
          email: 'test@example.com',
          photo: 'photos/user.jpg',
          role: 'employee',
          isActive: true,
        );

        // Act
        final photoUrl = user.photoUrl;

        // Assert
        expect(photoUrl, contains('photos/user.jpg'));
        expect(photoUrl, isNotEmpty);
      });

      test('should handle null photo', () {
        // Arrange
        final user = User(
          id: 2,
          name: 'Test User',
          email: 'test@example.com',
          photo: null,
          role: 'employee',
          isActive: true,
        );

        // Act
        final photoUrl = user.photoUrl;

        // Assert - ApiConfig.getStorageUrl handles null
        expect(photoUrl, isNotNull);
      });
    });

    group('Edge Cases', () {
      test('should handle empty string values', () {
        // Arrange
        final json = {
          'id': 1,
          'name': '',
          'email': '',
          'role': '',
          'is_active': 1,
        };

        // Act
        final user = User.fromJson(json);

        // Assert
        expect(user.name, '');
        expect(user.email, '');
        expect(user.role, '');
      });
    });
  });

  group('Company Model Tests', () {
    group('fromJson', () {
      test('should parse complete Company JSON correctly', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'PT Tech Indonesia',
          'email': 'info@tech.com',
          'phone': '021123456',
          'address': 'Jakarta Selatan',
          'latitude': -6.2088,
          'longitude': 106.8456,
          'radius': 100,
          'work_start_time': '08:00',
          'work_end_time': '17:00',
          'is_active': 1,
          'logo': 'logos/company.png',
        };

        // Act
        final company = Company.fromJson(json);

        // Assert
        expect(company.id, 1);
        expect(company.name, 'PT Tech Indonesia');
        expect(company.email, 'info@tech.com');
        expect(company.phone, '021123456');
        expect(company.address, 'Jakarta Selatan');
        expect(company.latitude, -6.2088);
        expect(company.longitude, 106.8456);
        expect(company.radius, 100);
        expect(company.workStartTime, '08:00');
        expect(company.workEndTime, '17:00');
        expect(company.isActive, true);
        expect(company.logo, 'logos/company.png');
      });

      test('should parse Company JSON with minimal fields', () {
        // Arrange
        final json = {
          'id': 2,
          'name': 'Startup Inc',
          'email': 'contact@startup.com',
          'radius': 50,
          'work_start_time': '09:00',
          'work_end_time': '18:00',
          'is_active': true,
        };

        // Act
        final company = Company.fromJson(json);

        // Assert
        expect(company.id, 2);
        expect(company.name, 'Startup Inc');
        expect(company.email, 'contact@startup.com');
        expect(company.radius, 50);
        expect(company.workStartTime, '09:00');
        expect(company.workEndTime, '18:00');
        expect(company.isActive, true);
        expect(company.phone, isNull);
        expect(company.address, isNull);
        expect(company.latitude, isNull);
        expect(company.longitude, isNull);
        expect(company.logo, isNull);
      });

      test('should handle is_active as boolean true', () {
        // Arrange
        final json = {
          'id': 3,
          'name': 'Test Company',
          'email': 'test@company.com',
          'radius': 100,
          'work_start_time': '08:00',
          'work_end_time': '17:00',
          'is_active': true,
        };

        // Act
        final company = Company.fromJson(json);

        // Assert
        expect(company.isActive, true);
      });

      test('should handle is_active as integer 1', () {
        // Arrange
        final json = {
          'id': 4,
          'name': 'Test Company',
          'email': 'test@company.com',
          'radius': 100,
          'work_start_time': '08:00',
          'work_end_time': '17:00',
          'is_active': 1,
        };

        // Act
        final company = Company.fromJson(json);

        // Assert
        expect(company.isActive, true);
      });

      test('should handle is_active as integer 0', () {
        // Arrange
        final json = {
          'id': 5,
          'name': 'Inactive Company',
          'email': 'inactive@company.com',
          'radius': 100,
          'work_start_time': '08:00',
          'work_end_time': '17:00',
          'is_active': 0,
        };

        // Act
        final company = Company.fromJson(json);

        // Assert
        expect(company.isActive, false);
      });
    });

    group('toJson', () {
      test('should convert Company to JSON correctly', () {
        // Arrange
        final company = Company(
          id: 1,
          name: 'PT Tech',
          email: 'info@tech.com',
          phone: '021123456',
          address: 'Jakarta',
          latitude: -6.2088,
          longitude: 106.8456,
          radius: 100,
          workStartTime: '08:00',
          workEndTime: '17:00',
          isActive: true,
          logo: 'logos/company.png',
        );

        // Act
        final json = company.toJson();

        // Assert
        expect(json['id'], 1);
        expect(json['name'], 'PT Tech');
        expect(json['email'], 'info@tech.com');
        expect(json['phone'], '021123456');
        expect(json['address'], 'Jakarta');
        expect(json['latitude'], -6.2088);
        expect(json['longitude'], 106.8456);
        expect(json['radius'], 100);
        expect(json['work_start_time'], '08:00');
        expect(json['work_end_time'], '17:00');
        expect(json['is_active'], true);
        expect(json['logo'], 'logos/company.png');
      });
    });

    group('Company Properties', () {
      test('should have correct radius value', () {
        // Arrange
        final company = Company(
          id: 1,
          name: 'Test Company',
          email: 'test@company.com',
          radius: 150,
          workStartTime: '08:00',
          workEndTime: '17:00',
          isActive: true,
        );

        // Act & Assert
        expect(company.radius, 150);
      });

      test('should store logo path correctly', () {
        // Arrange
        final company = Company(
          id: 2,
          name: 'Test Company',
          email: 'test@company.com',
          radius: 100,
          workStartTime: '08:00',
          workEndTime: '17:00',
          isActive: true,
          logo: 'logos/company.png',
        );

        // Act & Assert
        expect(company.logo, 'logos/company.png');
      });

      test('should handle null logo', () {
        // Arrange
        final company = Company(
          id: 3,
          name: 'Test Company',
          email: 'test@company.com',
          radius: 100,
          workStartTime: '08:00',
          workEndTime: '17:00',
          isActive: true,
          logo: null,
        );

        // Act & Assert
        expect(company.logo, isNull);
      });
    });
  });
}
