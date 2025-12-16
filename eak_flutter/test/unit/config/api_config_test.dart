import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/config/api_config.dart';

void main() {
  group('ApiConfig Tests', () {
    group('URL Construction', () {
      test('should return correct full URL with endpoint', () {
        // Arrange
        const endpoint = '/test-endpoint';

        // Act
        final result = ApiConfig.getFullUrl(endpoint);

        // Assert
        expect(result, '${ApiConfig.baseUrl}$endpoint');
        expect(result.startsWith('http'), isTrue);
      });

      test('should construct correct leave URL', () {
        // Act
        final result = ApiConfig.leaveUrl;

        // Assert
        expect(
          result,
          '${ApiConfig.baseUrl}${ApiConfig.leaveRequestsEndpoint}',
        );
        expect(result.contains('/leave-requests'), isTrue);
      });
    });

    group('Storage URL Helper', () {
      test('should return empty string for null path', () {
        // Act
        final result = ApiConfig.getStorageUrl(null);

        // Assert
        expect(result, isEmpty);
      });

      test('should return empty string for empty path', () {
        // Act
        final result = ApiConfig.getStorageUrl('');

        // Assert
        expect(result, isEmpty);
      });

      test('should return full URL when path already starts with http', () {
        // Arrange
        const fullUrl = 'http://example.com/image.jpg';

        // Act
        final result = ApiConfig.getStorageUrl(fullUrl);

        // Assert
        expect(result, fullUrl);
      });

      test('should return full URL when path already starts with https', () {
        // Arrange
        const fullUrl = 'https://example.com/image.jpg';

        // Act
        final result = ApiConfig.getStorageUrl(fullUrl);

        // Assert
        expect(result, fullUrl);
      });

      test('should construct storage URL for relative path', () {
        // Arrange
        const relativePath = 'photos/profile.jpg';

        // Act
        final result = ApiConfig.getStorageUrl(relativePath);

        // Assert
        expect(result, '${ApiConfig.storageUrl}/$relativePath');
      });

      test('should handle path starting with slash correctly', () {
        // Arrange
        const pathWithSlash = '/photos/profile.jpg';

        // Act
        final result = ApiConfig.getStorageUrl(pathWithSlash);

        // Assert
        expect(result, '${ApiConfig.storageUrl}/photos/profile.jpg');
        expect(
          result.contains('//photos'),
          isFalse,
        ); // Should not have double slash
      });
    });

    group('Development Mode Check', () {
      test('should detect development mode correctly', () {
        // Act
        final result = ApiConfig.isDevelopment;

        // Assert
        // Check if baseUrl contains development indicators
        final isLocalNetwork =
            ApiConfig.baseUrl.contains('192.168') ||
            ApiConfig.baseUrl.contains('localhost') ||
            ApiConfig.baseUrl.contains('127.0.0.1');

        expect(result, isLocalNetwork);
      });
    });

    group('Endpoint Constants', () {
      test('should have correct authentication endpoints', () {
        expect(ApiConfig.loginEndpoint, '/login');
        expect(ApiConfig.registerEndpoint, '/register');
        expect(ApiConfig.logoutEndpoint, '/logout');
        expect(ApiConfig.profileEndpoint, '/profile');
      });

      test('should have correct attendance endpoints', () {
        expect(ApiConfig.clockInEndpoint, '/attendance/clock-in');
        expect(ApiConfig.clockOutEndpoint, '/attendance/clock-out');
        expect(ApiConfig.todayAttendanceEndpoint, '/attendance/today');
        expect(ApiConfig.attendanceHistoryEndpoint, '/attendance/history');
      });

      test('should have correct leave request endpoint', () {
        expect(ApiConfig.leaveRequestsEndpoint, '/leave-requests');
      });

      test('should have correct company endpoint', () {
        expect(ApiConfig.companyEndpoint, '/company');
      });
    });

    group('Timeout Configuration', () {
      test('should have connection timeout of 30 seconds', () {
        expect(ApiConfig.connectionTimeout.inSeconds, 30);
      });

      test('should have receive timeout of 30 seconds', () {
        expect(ApiConfig.receiveTimeout.inSeconds, 30);
      });
    });

    group('Base URL Validation', () {
      test('should have valid base URL format', () {
        expect(ApiConfig.baseUrl.startsWith('http'), isTrue);
        expect(ApiConfig.baseUrl.contains('/api'), isTrue);
      });

      test('should have valid storage URL format', () {
        expect(ApiConfig.storageUrl.startsWith('http'), isTrue);
        expect(ApiConfig.storageUrl.contains('/storage'), isTrue);
      });
    });
  });
}
