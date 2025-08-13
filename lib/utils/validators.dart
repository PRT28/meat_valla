class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
      return 'Name can only contain letters and spaces';
    }
    
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    
    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the pin code';
    }
    
    if (value.length != 6) {
      return 'Pin code must be 6 digits';
    }
    
    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'Please enter a valid pin code';
    }
    
    return null;
  }

  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the address';
    }
    
    if (value.length < 10) {
      return 'Please enter a complete address';
    }
    
    return null;
  }

  static String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the city';
    }
    
    if (value.length < 2) {
      return 'Please enter a valid city name';
    }
    
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter the state';
    }
    
    if (value.length < 2) {
      return 'Please enter a valid state name';
    }
    
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Please enter $fieldName';
    }
    
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  static String? validateQuantity(String? value, double min, double max) {
    if (value == null || value.isEmpty) {
      return 'Please enter quantity';
    }
    
    final quantity = double.tryParse(value);
    if (quantity == null) {
      return 'Please enter a valid number';
    }
    
    if (quantity < min) {
      return 'Minimum quantity is $min';
    }
    
    if (quantity > max) {
      return 'Maximum quantity is $max';
    }
    
    return null;
  }

  static String? validateFeedbackMessage(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your message';
    }
    
    if (value.length < 10) {
      return 'Message must be at least 10 characters long';
    }
    
    if (value.length > 1000) {
      return 'Message cannot exceed 1000 characters';
    }
    
    return null;
  }
}