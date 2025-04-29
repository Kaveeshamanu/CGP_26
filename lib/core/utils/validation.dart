

import 'package:intl/intl.dart';

/// Utility class for form field validations throughout the app
class Validators {
  /// Validates an email address
  /// Returns null if valid, or an error message if invalid
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email address is required';
    }
    
    // Regular expression for email validation
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates a password
  /// Returns null if valid, or an error message if invalid
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    
    // Check for at least one uppercase letter
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one lowercase letter
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    // Check for at least one digit
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Validates password confirmation
  /// Returns null if matches, or an error message if it doesn't
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates a name field
  /// Returns null if valid, or an error message if invalid
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    // Check for valid name characters (letters, spaces, and some special characters)
    if (!RegExp(r'^[a-zA-Z\s\'-]+$').hasMatch(value)) {
      return 'Please enter a valid name';
    }
  }

  /// Validates a phone number
  /// Returns null if valid, or an error message if invalid
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters for validation
    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanValue.length < 10) {
      return 'Please enter a valid phone number';
    }
    
    return null;
  }

  /// Validates a date string in format YYYY-MM-DD
  /// Returns null if valid, or an error message if invalid
  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      final date = DateFormat('yyyy-MM-dd').parseStrict(value);
      
      // Check if date is in the past
      if (date.isAfter(DateTime.now())) {
        return 'Date cannot be in the future';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
  }

  /// Validates a future date string in format YYYY-MM-DD
  /// Returns null if valid, or an error message if invalid
  String? validateFutureDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date is required';
    }
    
    try {
      final date = DateFormat('yyyy-MM-dd').parseStrict(value);
      
      // Check if date is in the future
      if (date.isBefore(DateTime.now())) {
        return 'Date must be in the future';
      }
      
      return null;
    } catch (e) {
      return 'Please enter a valid date (YYYY-MM-DD)';
    }
  }

  /// Validates a numeric value
  /// Returns null if valid, or an error message if invalid
  String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    
    if (double.tryParse(value) == null) {
      return 'Please enter a valid number';
    }
    
    return null;
  }

  /// Validates a URL
  /// Returns null if valid, or an error message if invalid
  String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegExp = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    
    if (!urlRegExp.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Validates that a required field is not empty
  /// Returns null if valid, or an error message if invalid
  String? validateRequired(String? value, {String fieldName = 'This field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  /// Validates text length
  /// Returns null if valid, or an error message if invalid
  String? validateLength(String? value, {int min = 0, int max = 255, String fieldName = 'This field'}) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (value.isEmpty && min > 0) {
      return '$fieldName is required';
    }
    
    if (value.length < min) {
      return '$fieldName must be at least $min characters long';
    }
    
    if (value.length > max) {
      return '$fieldName cannot exceed $max characters';
    }
    
    return null;
  }

  /// Validates username
  /// Returns null if valid, or an error message if invalid
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters long';
    }
    
    if (value.length > 20) {
      return 'Username cannot exceed 20 characters';
    }
    
    // Check for valid username characters (letters, numbers, underscore, dot)
    if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, periods and underscores';
    }
    
    return null;
  }

  /// Validates a Sri Lankan postal code
  /// Returns null if valid, or an error message if invalid
  String? validateSriLankanPostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Postal code is optional
    }
    
    // Sri Lankan postal codes are 5 digits
    if (!RegExp(r'^\d{5}$').hasMatch(value)) {
      return 'Please enter a valid 5-digit postal code';
    }
    
    return null;
  }

  /// Validates a credit card number (basic validation)
  /// Returns null if valid, or an error message if invalid
  String? validateCreditCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Credit card number is required';
    }
    
    // Remove any spaces or dashes
    final cleanValue = value.replaceAll(RegExp(r'[\s-]'), '');
    
    // Check if it's all digits
    if (!RegExp(r'^\d+$').hasMatch(cleanValue)) {
      return 'Credit card number can only contain digits';
    }
    
    // Check length (most cards are 13-19 digits)
    if (cleanValue.length < 13 || cleanValue.length > 19) {
      return 'Please enter a valid credit card number';
    }
    
    // Luhn algorithm check (https://en.wikipedia.org/wiki/Luhn_algorithm)
    int sum = 0;
    bool alternate = false;
    for (int i = cleanValue.length - 1; i >= 0; i--) {
      int digit = int.parse(cleanValue[i]);
      
      if (alternate) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }
      
      sum += digit;
      alternate = !alternate;
    }
    
    if (sum % 10 != 0) {
      return 'Please enter a valid credit card number';
    }
    
    return null;
  }

  /// Validates a CVV code
  /// Returns null if valid, or an error message if invalid
  String? validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV is required';
    }
    
    // CVV is typically 3 or 4 digits
    if (!RegExp(r'^\d{3,4}$').hasMatch(value)) {
      return 'Please enter a valid CVV code';
    }
    
    return null;
  }

  /// Validates a review rating (1-5)
  /// Returns null if valid, or an error message if invalid
  String? validateRating(double? value) {
    if (value == null) {
      return 'Rating is required';
    }
    
    if (value < 1.0 || value > 5.0) {
      return 'Rating must be between 1 and 5';
    }
    
    return null;
  }
}