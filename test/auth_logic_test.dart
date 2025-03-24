// test/auth_logic_test.dart
import 'package:flutter_test/flutter_test.dart';

// Simple authentication class for testing
class AuthLogic {
  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  bool isStrongPassword(String password) {
    // Check length
    if (password.length < 8) return false;
    
    // Check for number
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    
    // Check for uppercase
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    
    return true;
  }
  
  String? validateRegistrationData(String email, String password, String confirmPassword) {
    if (!isValidEmail(email)) {
      return 'Invalid email format';
    }
    
    if (!isStrongPassword(password)) {
      return 'Password must be at least 8 characters with numbers and uppercase letters';
    }
    
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    
    return null; // No error
  }
}

void main() {
  group('Authentication Logic', () {
    late AuthLogic authLogic;
    
    setUp(() {
      authLogic = AuthLogic();
    });
    
    test('Email validation works correctly', () {
      // Valid emails
      expect(authLogic.isValidEmail('test@example.com'), true);
      expect(authLogic.isValidEmail('user.name@domain.co.uk'), true);
      
      // Invalid emails
      expect(authLogic.isValidEmail('invalid'), false);
      expect(authLogic.isValidEmail('missing@dot'), false);
      expect(authLogic.isValidEmail('@example.com'), false);
    });
    
    test('Password strength check works correctly', () {
      // Strong passwords
      expect(authLogic.isStrongPassword('Password123'), true);
      expect(authLogic.isStrongPassword('StrongPwd1'), true);
      
      // Weak passwords
      expect(authLogic.isStrongPassword('password'), false); // No uppercase, no number
      expect(authLogic.isStrongPassword('Password'), false); // No number
      expect(authLogic.isStrongPassword('password1'), false); // No uppercase
      expect(authLogic.isStrongPassword('Pass1'), false); // Too short
    });
    
    test('Registration validation works correctly', () {
      // Valid registration
      expect(
        authLogic.validateRegistrationData('test@example.com', 'Password123', 'Password123'),
        null
      );
      
      // Invalid email
      expect(
        authLogic.validateRegistrationData('invalid', 'Password123', 'Password123'),
        'Invalid email format'
      );
      
      // Weak password
      expect(
        authLogic.validateRegistrationData('test@example.com', 'password', 'password'),
        'Password must be at least 8 characters with numbers and uppercase letters'
      );
      
      // Passwords don't match
      expect(
        authLogic.validateRegistrationData('test@example.com', 'Password123', 'DifferentPass123'),
        'Passwords do not match'
      );
    });
  });
}