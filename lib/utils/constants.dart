class AppConstants {
  // API Base URL (Update with your backend URL)
  static const String baseUrl = 'https://api.proplilly.com';
  
  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';
  
  // Geo-fencing
  static const double visitGeoRadius = 100.0; // meters
  
  // File Upload
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageFormats = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentFormats = ['pdf', 'jpg', 'jpeg', 'png'];
  
  // OTP
  static const int otpLength = 6;
  static const int otpResendCooldown = 60; // seconds

}
