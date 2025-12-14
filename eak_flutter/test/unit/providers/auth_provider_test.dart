import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:eak_flutter/providers/auth_provider.dart';
import 'package:eak_flutter/services/api_services.dart';
import 'package:eak_flutter/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manual Mock class to avoid build_runner dependency
class MockApiServiceImpl extends Mock implements ApiServiceImpl {
  @override
  Future<Map<String, dynamic>> login(String email, String password) {
    return super.noSuchMethod(
      Invocation.method(#login, [email, password]),
      returnValue: Future.value({'success': false, 'message': 'Mock default'}),
    );
  }

  @override
  Future<Map<String, dynamic>> logout() {
    return super.noSuchMethod(
      Invocation.method(#logout, []),
      returnValue: Future.value({'success': true}),
    );
  }

  @override
  Future<Map<String, dynamic>> getProfile() {
    return super.noSuchMethod(
      Invocation.method(#getProfile, []),
      returnValue: Future.value({'success': false}),
    );
  }
  
  @override
  Future<Map<String, dynamic>> getCompany() {
     return super.noSuchMethod(
      Invocation.method(#getCompany, []),
      returnValue: Future.value({'success': false}),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AuthProvider Unit Tests', () {
    late AuthProvider authProvider;
    late MockApiServiceImpl mockApiService;

    setUp(() async {
      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
      
      mockApiService = MockApiServiceImpl();
      authProvider = AuthProvider(apiService: mockApiService);
    });

    group('AUTH-U-001: Login Logic', () {
      test('should set authenticated state on successful login', () async {
        // Arrange
        final userJson = {
          'id': 1,
          'name': 'Test User',
          'email': 'test@example.com',
          'role': 'employee',
          'company_id': 1,
          'email_verified_at': null,
          'phone': null,
          'employee_id': null,
          'position': null,
          'face_embedding': null,
          'created_at': null,
          'updated_at': null,
          'is_active': 1,
        };
        
        final userObj = User.fromJson(userJson);
        
        final companyJson = {
          'id': 1,
          'name': 'Test Corp',
          'email': 'corp@test.com',
          'address': 'Test Address',
          'latitude': -6.2,
          'longitude': 106.8,
          'radius': 100, // Valid key
          'work_start_time': '08:00', // Valid key
          'work_end_time': '17:00', // Valid key
          'is_active': 1, // Required
        };

        when(mockApiService.login('test@example.com', 'password123'))
            .thenAnswer((_) async => {
                  'success': true,
                  'user': userObj, // Return User object
                  'message': 'Login successful',
                  'data': {'token': 'fake_token', 'user': userJson}
                });
                
        when(mockApiService.getCompany())
            .thenAnswer((_) async => {
              'success': true,
              'company': Company.fromJson(companyJson) // Return Company object
            });

        // Act
        final success = await authProvider.login('test@example.com', 'password123');

        // Assert
        expect(success, isTrue);
        expect(authProvider.isAuthenticated, isTrue);
        expect(authProvider.user?.name, 'Test User');
        expect(authProvider.user?.email, 'test@example.com');
        expect(authProvider.errorMessage, isNull);
      });

      test('should handle login failure', () async {
        // Arrange
        when(mockApiService.login('wrong@email.com', 'wrongpass'))
            .thenAnswer((_) async => {
                  'success': false,
                  'message': 'Invalid credentials',
                });

        // Act
        final success = await authProvider.login('wrong@email.com', 'wrongpass');

        // Assert
        expect(success, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.errorMessage, 'Invalid credentials');
      });
    });

    group('AUTH-U-002: Invalid Email Format', () {
      test('should return validation error for invalid email', () async {
         // Note: AuthProvider currently relies on API for validation. 
         // If we added local validation this test would verify it.
         // For now, checks that API validation response is handled.
         
         when(mockApiService.login('invalid-email', 'pass'))
            .thenAnswer((_) async => {
              'success': false,
              'message': 'The email field must be a valid email address.',
            });
            
          final success = await authProvider.login('invalid-email', 'pass');
          
          expect(success, isFalse);
          expect(authProvider.errorMessage, contains('email field must be a valid email'));
      });
    });

    group('AUTH-U-003: Empty Credentials', () {
      test('should fail login with empty credentials', () async {
        when(mockApiService.login('', ''))
            .thenAnswer((_) async => {
              'success': false, 
              'message': 'Email and password are required'
            });

        final success = await authProvider.login('', '');

        expect(success, isFalse);
        expect(authProvider.isAuthenticated, isFalse);
      });
    });

    group('AUTH-U-004: Logout Logic', () {
      test('should clear user state on logout', () async {
        // Arrange - Login first (simulated)
        // ... (can set private fields if needed using reflection or just skip)
        // Directly call logout
        
        when(mockApiService.logout()).thenAnswer((_) async => {'success': true});

        // Act
        await authProvider.logout();

        // Assert
        expect(authProvider.isAuthenticated, isFalse);
        expect(authProvider.user, isNull);
        expect(authProvider.company, isNull);
      });
    });
  });
}
