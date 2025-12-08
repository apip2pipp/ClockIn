import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:eak_flutter/screens/login_screen.dart';
import 'package:eak_flutter/providers/auth_provider.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    // Helper function to wrap widget with Provider
    Widget createLoginScreen() {
      return MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
        child: const MaterialApp(home: LoginScreen()),
      );
    }

    testWidgets('should display logo, email and password fields', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act & Assert
      expect(find.byType(Image), findsOneWidget); // Logo
      expect(find.byType(TextFormField), findsNWidgets(2)); // Email & Password
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display login button', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act & Assert
      expect(find.text('Masuk'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - Find visibility toggle
      final visibilityToggle = find.byIcon(Icons.visibility_off_outlined);

      // Assert - Initially password is obscured
      expect(visibilityToggle, findsOneWidget);

      // Act - Tap visibility toggle
      await tester.tap(visibilityToggle);
      await tester.pump();

      // Assert - Now showing visibility icon
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('should show validation error for empty email', (tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - Tap login without filling email
      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert - Validation error appears
      expect(find.text('Email tidak boleh kosong'), findsOneWidget);
    });

    testWidgets('should show validation error for invalid email', (
      tester,
    ) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());

      // Act - Enter invalid email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'invalidemail');

      // Tap login
      final loginButton = find.text('Masuk');
      await tester.tap(loginButton);
      await tester.pump();

      // Assert
      expect(find.text('Email tidak valid'), findsOneWidget);
    });

    testWidgets('should show validation error for short password', (
      tester,
    ) async {
      // TODO: Test password length validation
    });

    testWidgets('should show loading indicator when logging in', (
      tester,
    ) async {
      // TODO: Test loading state
      // Hint: Mock login and verify CircularProgressIndicator appears
    });

    testWidgets('should navigate to home after successful login', (
      tester,
    ) async {
      // TODO: Test navigation
      // Hint: Mock successful login and verify navigation
    });
  });
}
