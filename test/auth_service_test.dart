// test/auth_service_test.dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Auth Tests', () {
    test('Email validation works correctly', () {
      // A better email validation function
      bool isValidEmail(String email) {
        // Simple regex for email validation
        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
        return emailRegex.hasMatch(email);
      }
      
      // Test valid emails
      expect(isValidEmail('test@example.com'), true);
      expect(isValidEmail('user.name@domain.org'), true);
      
      // Test invalid emails
      expect(isValidEmail('notanemail'), false);
      expect(isValidEmail('missing@dot'), false);
      expect(isValidEmail('@nodomain.com'), false);
    });
    
    test('Password validation works correctly', () {
      // Password validation function
      bool isStrongPassword(String password) {
        return password.length >= 6;
      }
      
      // Test valid passwords
      expect(isStrongPassword('password123'), true);
      expect(isStrongPassword('123456'), true);
      
      // Test invalid passwords
      expect(isStrongPassword('12345'), false);
      expect(isStrongPassword(''), false);
    });
  });
}