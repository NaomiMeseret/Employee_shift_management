import 'package:flutter/foundation.dart';

class AppConfig {
  // Dynamic API base URL that adapts to different environments
  static String get apiBaseUrl {
    
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    
   
    const environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');
    
    switch (environment) {
      case 'production':
        return 'https://your-api-domain.com/api';  // Replace with your production URL
      case 'staging':
        return 'https://staging-api-domain.com/api';  // Replace with your staging URL
      case 'development':
      default:
        // Development URLs for different platforms
        if (kIsWeb) {
          return 'http://localhost:3000/api';  // Web development
        } else {
          // For mobile: Check environment variable first, then use emulator default
          const customIP = String.fromEnvironment('API_IP');
          if (customIP.isNotEmpty) {
            return 'http://$customIP:3000/api';  // Custom IP
          }
          return 'http://10.0.2.2:3000/api';  // Default: Android emulator
        }
    }
  }

  static const String appName = 'Employee Shift Management';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String employeesEndpoint = '/employees';
  static const String shiftsEndpoint = '/assignedShift';  // Updated to match backend
  static const String attendanceEndpoint = '/attendance';
  static const String assignShiftEndpoint = '/assignShift';
  static const String updateShiftEndpoint = '/shift';

  // Shared Preferences Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Error Messages
  static const String networkError = 'Network error occurred. Please check your connection.';
  static const String serverError = 'Server error occurred. Please try again later.';
  static const String unauthorizedError = 'Unauthorized access. Please login again.';
  static const String notFoundError = 'Resource not found.';
  static const String unknownError = 'An unknown error occurred.';

  // Success Messages
  static const String employeeAdded = 'Employee added successfully.';
  static const String employeeUpdated = 'Employee updated successfully.';
  static const String employeeDeleted = 'Employee deleted successfully.';
  static const String shiftAdded = 'Shift added successfully.';
  static const String shiftUpdated = 'Shift updated successfully.';
  static const String shiftDeleted = 'Shift deleted successfully.';
  static const String attendanceUpdated = 'Attendance updated successfully.';
  static const String attendanceDeleted = 'Attendance record deleted successfully.';
} 