class ValidationService {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    return null;
  }

  static String? validateEmployeeId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee ID is required';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Employee ID must contain only numbers';
    }
    
    return null;
  }

  static String? validatePosition(String? value) {
    if (value == null || value.isEmpty) {
      return 'Position is required';
    }
    
    if (value.length < 2) {
      return 'Position must be at least 2 characters long';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validatePasswordConfirmation(String? password, String? confirmation) {
    if (confirmation == null || confirmation.isEmpty) {
      return 'Password confirmation is required';
    }
    
    if (password != confirmation) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static bool isValidEmail(String email) {
    return validateEmail(email) == null;
  }

  static bool isValidPassword(String password) {
    return validatePassword(password) == null;
  }

  static bool isValidPhone(String phone) {
    return validatePhone(phone) == null;
  }

  static String formatPhoneNumber(String phone) {
    final digitsOnly = phone.replaceAll(RegExp(r'\D'), '');
    if (digitsOnly.length >= 10) {
      return '(${digitsOnly.substring(0, 3)}) ${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6, 10)}';
    }
    return phone;
  }

  static String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
