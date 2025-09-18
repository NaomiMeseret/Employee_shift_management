class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:'http://localhost:3000/api',
  );

  static const String appName = 'Employee Shift Management';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String employeesEndpoint = '/employees';
  static const String shiftsEndpoint = '/shift';
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