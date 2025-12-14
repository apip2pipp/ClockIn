import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:eak_flutter/main.dart';
import 'package:eak_flutter/services/api_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import Mock Helpers from test directory
import '../test/integration/helpers/mock_http_client.dart';
import '../test/integration/helpers/mock_location_service.dart';
import '../test/integration/helpers/mock_image_picker_service.dart';
import 'package:eak_flutter/services/location_service.dart';
import 'package:eak_flutter/services/image_picker_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E Application Tests', () {
    late ApiServiceImpl testApiService;

    setUp(() async {
      // 1. Setup Mock HTTP Client capable of handling Auth & Profile
      final mockClient = MockHttpHelper.createAuthMock();
      
      // 2. Initialize Service with Mock Client
      testApiService = ApiServiceImpl(client: mockClient);
      
      // 3. Inject into Singleton for App to use
      ApiService.setInstance(testApiService);
      
      // 4. Reset SharedPreferences for clean state
      SharedPreferences.setMockInitialValues({
        'hasSeenOnboarding': true,
      });

      // 5. Inject Mock Location & Image Picker Services
      LocationService.setInstance(MockLocationService());
      ImagePickerService.setInstance(MockImagePickerService());
    });

    testWidgets('Complete Login Flow: Login -> Dashboard -> Logout', (tester) async {
      // 1. Start App
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 4)); // Wait for Splash (3s delay)

      // 2. Verify Login Screen
      expect(find.text('ClockIn'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password

      // 3. Enter Credentials
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'), 
        'test@example.com'
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'), 
        'password123'
      );
      await tester.pump();

      // 4. Tap Login Button
      // Assuming button has text 'Login' or specific Key
      // If UI uses "Masuk", adjust here. Checking login_screen.dart later if needed.
      // Trying generic logical finders first.
      var loginButton = find.text('Masuk');
      
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // 5. Verify Dashboard (Home Screen)
      // Check for user name from Mock "Test User"
      expect(find.text('Test User'), findsOneWidget);
      
      // "Clock In" text appears twice (Status Chip and Big Button State or Title)
      // Let's verify we are on Home Screen by finding the specific top header or Bottom Tab
      expect(find.text('Attendance'), findsOneWidget); 
      expect(find.text('My Leaves'), findsOneWidget);

      // 6. Perform Logout
      // Tap Profile Icon in Header
      await tester.tap(find.byKey(const Key('profile_button')));
      await tester.pumpAndSettle();

      // Verify Profile Screen
      expect(find.text('Profile'), findsOneWidget);
      
      // Find Logout button (might be at bottom, so scroll/ensure visible)
      // Manual scroll down using generic drag from center
      await tester.dragFrom(const Offset(200, 500), const Offset(0, -300));
      await tester.pumpAndSettle();
      
      final logoutFinder = find.text('Logout');
      expect(logoutFinder, findsOneWidget);

      // Tap Logout Button
      await tester.tap(logoutFinder);
      await tester.pumpAndSettle();

      // Confirm Logout Dialog
      // Find "Logout" text in the dialog (TextButton)
      final confirmLogoutFinder = find.widgetWithText(TextButton, 'Logout');
      expect(confirmLogoutFinder, findsOneWidget);
      await tester.tap(confirmLogoutFinder);
      await tester.pumpAndSettle();

      // Verify return to Login Screen
      expect(find.text('Masuk'), findsOneWidget);
    });

    
    testWidgets('Complete Clock In Flow: Login -> Clock In Screen -> Submit -> Dashboard', (tester) async {
       // 1. Start App
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // 2. Perform Login (Reuse steps)
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'test@example.com');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.pump();
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      // 3. Verify Dashboard
      expect(find.text('Test User'), findsOneWidget);

      // 4. Tap Clock In Card (Big card in center/top)
      // The card usually has 'Clock In' title or 00:00 time. 
      // Based on HomeScreen code, there is a "Clock In" text.
      // But let's look for a GestureDetector or InkWell wrapping the clock card.
      // Or just tap the "Clock In" text if it's there. 
      // Note: "Attendance" was confirmed earlier. "Clock In" might be on the card status.
      // Finder strategy: Tap the "Attendance" text? No, that's header.
      // The button/card says "Clock In" if not attended.
      // Let's assume the text "Clock In" is tappable or inside the tappable card.
      // 4. Tap Clock In Card
      // The button text is "Tap to Clock In" when no attendance exists
      final clockInFinder = find.text('Tap to Clock In');
      expect(clockInFinder, findsOneWidget);
      
      await tester.tap(clockInFinder);
      await tester.pumpAndSettle();

      // 5. Verify Clock In Screen Navigation
      expect(find.text('Take Photo'), findsOneWidget); 
      expect(find.text('Activity Description'), findsOneWidget);

      // 6. Step 1: Take Photo (Mocked)
      // Find "Take Photo" button (ElevatedButton)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Take Photo'));
      await tester.pumpAndSettle();
      // Should show "Retake" button if success
      expect(find.text('Retake'), findsOneWidget);

      // 7. Step 2: Description
      await tester.enterText(find.byType(TextField), 'Testing E2E Clock In');
      await tester.pump();

      // 8. Step 3: Get Location (Mocked)
      await tester.tap(find.widgetWithText(ElevatedButton, 'Get Current Location'));
      await tester.pump(); // Allow Future to complete
      await tester.pump(); // Rebuild with location
      // Should verify lat/long text presence
      expect(find.textContaining('Latitude:'), findsOneWidget);

      // 9. Submit
      await tester.tap(find.text('Submit Clock In'));
      await tester.pumpAndSettle();

      // 10. Verify Success & Return to Dashboard
      // Expect SnackBar "Clock in successful!"
      expect(find.textContaining('successful'), findsOneWidget);
      
      // Verify Dashboard and updated status
      // Note: Mock API returns success, so Dashboard should update.
      // But our Mock API might return same "Attendance" object unless we state-manage the mock?
      // MockHttpHelper is stateless unless we modified it.
      // The Dashboard might rely on `_todayAttendance`.
      // The test passed if we are back on Dashboard.
      expect(find.text('Test User'), findsOneWidget);
    });

  });
}
