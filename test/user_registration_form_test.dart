import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_lab/widgets/user_registration_form.dart';
import 'package:flutter_testing_lab/utils/validation.dart';
import 'package:flutter/material.dart';

void main() {
  group('User Registration Form - Unit Tests', () {
    group('Email Validation', () {
      test('Valid email addresses should pass validation', () {
        expect(Validation.isValidEmail('test@example.com'), true);
        expect(Validation.isValidEmail('user.name@domain.co'), true);
        expect(Validation.isValidEmail('user-name@test-domain.org'), true);
        expect(Validation.isValidEmail('test.user_123@sub.domain.com'), true);
      });

      test('Invalid email addresses should fail validation', () {
        expect(Validation.isValidEmail(''), false);
        expect(Validation.isValidEmail('invalid'), false);
        expect(Validation.isValidEmail('invalid@'), false);
        expect(Validation.isValidEmail('@example.com'), false);
        expect(Validation.isValidEmail('invalid@.com'), false);
        expect(Validation.isValidEmail('invalid@domain'), false);
        expect(Validation.isValidEmail('invalid.domain.com'), false);
        expect(Validation.isValidEmail('invalid @example.com'), false);
      });

      test('Edge case email addresses', () {
        expect(Validation.isValidEmail('a@b.co'), true);
        expect(Validation.isValidEmail('test@domain.toolong'), false); // > 4 chars TLD
      });
    });

    group('Password Validation', () {
      test('Valid passwords should pass validation', () {
        expect(Validation.isValidPassword('Password1!'), true);
        expect(Validation.isValidPassword('Str0ng#Pass'), true);
        expect(Validation.isValidPassword('MyP@ssw0rd'), true);
        expect(Validation.isValidPassword('Test123!ABC'), true);
      });

      test('Passwords without minimum 8 characters should fail', () {
        expect(Validation.isValidPassword('Pass1!'), false);
        expect(Validation.isValidPassword('Ab1!'), false);
      });

      test('Passwords without uppercase should fail', () {
        expect(Validation.isValidPassword('password1!'), false);
        expect(Validation.isValidPassword('testpass1!'), false);
      });

      test('Passwords without number should fail', () {
        expect(Validation.isValidPassword('Password!'), false);
        expect(Validation.isValidPassword('TestPass!'), false);
      });

      test('Passwords without special character should fail', () {
        expect(Validation.isValidPassword('Password1'), false);
        expect(Validation.isValidPassword('TestPass123'), false);
      });

      test('Empty password should fail', () {
        expect(Validation.isValidPassword(''), false);
      });

      test('Password with all requirements should pass', () {
        expect(Validation.isValidPassword('ValidPass1!'), true);
        expect(Validation.isValidPassword('Test@123Pass'), true);
      });
    });
  });

  group('User Registration Form - Widget Tests', () {
    testWidgets('Form should display all input fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.text('Full Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('Should show error for invalid email', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Enter invalid email
      await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'invalid');
      
      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Please enter a valid email'), findsOneWidget);
    });

    testWidgets('Should show error for weak password', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Enter weak password
      final passwordField = find.widgetWithText(TextFormField, 'Password');
      await tester.enterText(passwordField, 'weak');
      
      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Password must be at least 8 characters with uppercase, number, and special character'), findsOneWidget);
    });

    testWidgets('Should show error when passwords do not match', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Find password fields by their position
      final textFields = find.byType(TextFormField);
      final passwordField = textFields.at(2); // Password field
      final confirmPasswordField = textFields.at(3); // Confirm Password field

      // Enter different passwords
      await tester.enterText(passwordField, 'Password1!');
      await tester.enterText(confirmPasswordField, 'Password2!');
      
      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('Should show error message when trying to submit with invalid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Tap register button without filling fields
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Please fix all errors before submitting'), findsOneWidget);
    });

    testWidgets('Should successfully submit with valid data', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Find all text fields
      final textFields = find.byType(TextFormField);

      // Enter valid data
      await tester.enterText(textFields.at(0), 'John Doe'); // Name
      await tester.enterText(textFields.at(1), 'test@example.com'); // Email
      await tester.enterText(textFields.at(2), 'Password1!'); // Password
      await tester.enterText(textFields.at(3), 'Password1!'); // Confirm Password

      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pump(); // Start the async operation

      // Should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for the simulated API call to complete
      await tester.pumpAndSettle();

      // Check for success message
      expect(find.text('Registration successful!'), findsOneWidget);
    });

    testWidgets('Should validate empty name field', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Tap register button without filling name
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Please enter your full name'), findsOneWidget);
    });

    testWidgets('Should validate minimum name length', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserRegistrationForm(),
          ),
        ),
      );

      // Enter single character name
      await tester.enterText(find.widgetWithText(TextFormField, 'Full Name'), 'A');
      
      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pumpAndSettle();

      // Check for error message
      expect(find.text('Name must be at least 2 characters'), findsOneWidget);
    });
  });
}

