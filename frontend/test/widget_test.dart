import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:employee_shift_management/main.dart';
import 'package:employee_shift_management/presentation/screens/login_screen.dart';
import 'package:employee_shift_management/application/services/validation_service.dart';

void main() {
  group('ShiftMaster App Tests', () {
    testWidgets('App should start with login screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: ShiftMasterApp(),
        ),
      );

      // Verify that the login screen is displayed
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.text('ShiftMaster'), findsOneWidget);
    });

    testWidgets('Login screen should have required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      // Verify email and password fields exist
      expect(find.byType(TextField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign in'), findsOneWidget);
    });
  });

  group('Validation Service Tests', () {
    test('Email validation should work correctly', () {
      expect(ValidationService.validateEmail(''), 'Email is required');
      expect(ValidationService.validateEmail('invalid-email'), 'Please enter a valid email address');
      expect(ValidationService.validateEmail('test@example.com'), null);
      expect(ValidationService.validateEmail('user.name+tag@domain.co.uk'), null);
    });

    test('Password validation should work correctly', () {
      expect(ValidationService.validatePassword(''), 'Password is required');
      expect(ValidationService.validatePassword('123'), 'Password must be at least 6 characters long');
      expect(ValidationService.validatePassword('password123'), null);
    });

    test('Name validation should work correctly', () {
      expect(ValidationService.validateName(''), 'Name is required');
      expect(ValidationService.validateName('A'), 'Name must be at least 2 characters long');
      expect(ValidationService.validateName('John123'), 'Name can only contain letters and spaces');
      expect(ValidationService.validateName('John Doe'), null);
    });

    test('Phone validation should work correctly', () {
      expect(ValidationService.validatePhone(''), 'Phone number is required');
      expect(ValidationService.validatePhone('123'), 'Phone number must be at least 10 digits');
      expect(ValidationService.validatePhone('1234567890'), null);
      expect(ValidationService.validatePhone('(123) 456-7890'), null);
    });

    test('Employee ID validation should work correctly', () {
      expect(ValidationService.validateEmployeeId(''), 'Employee ID is required');
      expect(ValidationService.validateEmployeeId('abc'), 'Employee ID must contain only numbers');
      expect(ValidationService.validateEmployeeId('12345'), null);
    });

    test('Password confirmation validation should work correctly', () {
      expect(ValidationService.validatePasswordConfirmation('password', ''), 'Password confirmation is required');
      expect(ValidationService.validatePasswordConfirmation('password', 'different'), 'Passwords do not match');
      expect(ValidationService.validatePasswordConfirmation('password', 'password'), null);
    });
  });

  group('Utility Functions Tests', () {
    test('Phone number formatting should work correctly', () {
      expect(ValidationService.formatPhoneNumber('1234567890'), '(123) 456-7890');
      expect(ValidationService.formatPhoneNumber('123-456-7890'), '(123) 456-7890');
      expect(ValidationService.formatPhoneNumber('123'), '123');
    });

    test('Input sanitization should work correctly', () {
      expect(ValidationService.sanitizeInput('  Hello   World  '), 'Hello World');
      expect(ValidationService.sanitizeInput('\t\nTest\t\n'), 'Test');
    });

    test('Email validation helper should work correctly', () {
      expect(ValidationService.isValidEmail('test@example.com'), true);
      expect(ValidationService.isValidEmail('invalid-email'), false);
    });

    test('Password validation helper should work correctly', () {
      expect(ValidationService.isValidPassword('password123'), true);
      expect(ValidationService.isValidPassword('123'), false);
    });

    test('Phone validation helper should work correctly', () {
      expect(ValidationService.isValidPhone('1234567890'), true);
      expect(ValidationService.isValidPhone('123'), false);
    });
  });
}
