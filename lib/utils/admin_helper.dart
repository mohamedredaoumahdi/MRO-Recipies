class AdminHelper {
  static const String adminEmail = "test@test.com"; // Your admin email
  
  static bool isAdminEmail(String email) {
    return email.toLowerCase() == adminEmail.toLowerCase();
  }
} 