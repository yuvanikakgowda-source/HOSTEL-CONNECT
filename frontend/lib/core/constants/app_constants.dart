// frontend/lib/core/constants/app_constants.dart
class AppConstants {
  // API Configuration
  static const String apiBaseUrl = 'http://localhost:5001/api';
  static const String apiTimeout = '30000'; // milliseconds

  // Hostel Coordinates
  static const double hostelLatitude = 13.423190;
  static const double hostelLongitude = 77.146814;
  static const int geofenceRadius = 500; // meters

  // Attendance Timing
  static const int morningStartHour = 7;
  static const int morningStartMinute = 30;
  static const int morningEndHour = 9;
  static const int morningEndMinute = 0;

  static const int eveningStartHour = 18;
  static const int eveningStartMinute = 30;
  static const int eveningEndHour = 20;
  static const int eveningEndMinute = 0;

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyRole = 'user_role';
  static const String storageKeyUserId = 'user_id';
  static const String storageKeyThemeMode = 'theme_mode';

  // Error Messages
  static const String errorGeneric = 'Something went wrong. Please try again.';
  static const String errorNetwork =
      'Network error. Please check your connection.';
  static const String errorUnauthorized = 'Unauthorized. Please login again.';
  static const String errorStudentAccess =
      "Students can't access the warden page";
}
