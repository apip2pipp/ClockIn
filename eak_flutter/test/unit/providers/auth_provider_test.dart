import 'package:flutter_test/flutter_test.dart';
import 'package:eak_flutter/providers/auth_provider.dart';

void main() {
  // Initialize Flutter binding for tests that need SharedPreferences/SecureStorage
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider Tests', () {
    late AuthProvider authProvider;

    setUp(() {
      authProvider = AuthProvider();
    });

    tearDown(() {
      authProvider.dispose();
    });

    group('Initialization Tests', () {
      test('should initialize with default values', () {
        // Assert
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.errorMessage, isNull);
        expect(authProvider.isLoading, isFalse);
      });
    });

    group('Login Tests', () {
      // NOTE: Karena ApiService menggunakan static methods dan real HTTP calls,
      // test ini membutuhkan backend server yang running
      // Untuk pure unit test, ApiService perlu di-refactor jadi non-static

      // DISABLED: Test ini di-skip karena memerlukan real API call
      // Akan di-enable setelah ApiService refactored ke dependency injection

      // test('should set loading state when login starts', () async {
      //   // This test requires real backend API
      //   // Skip for now until ApiService supports dependency injection
      // });

      // TODO: For real unit tests, refactor ApiService to use dependency injection
      // Example: AuthProvider(apiService: MockApiService())
    });

    group('Logout Tests', () {
      // DISABLED: Test ini di-skip karena logout() memanggil ApiService.logout()
      // yang memerlukan real backend API dan SharedPreferences
      // Akan di-enable setelah ApiService refactored ke dependency injection

      // test('should clear user data on logout', () async {
      //   // This test requires real API call and SharedPreferences
      //   // Skip for now until ApiService supports dependency injection
      // });

      // TODO: Test token clearing from storage after DI implementation
    });

    group('Get User Profile Tests', () {
      // DISABLED: Test ini di-skip karena getUserProfile() memanggil real API
      // Akan di-enable setelah ApiService refactored ke dependency injection

      // test('should fetch and parse user profile successfully', () async {
      //   // This test requires real API call
      //   // Skip for now until ApiService supports dependency injection
      // });

      // test('should handle profile fetch error', () async {
      //   // This test requires real API call
      //   // Skip for now until ApiService supports dependency injection
      // });
    });
  });
}
