class AuthValidators {
  AuthValidators._();

  static final RegExp _phoneRegExp = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  /// Validates Indian 10-digit mobile number starting with 6, 7, 8, or 9
  static String? validatePhoneNumber(String? value) => validatePhone(value);
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter mobile number';
    }
    final clean = value.replaceAll(RegExp(r'\s+|-'), '').trim();
    if (clean.length != 10) {
      return 'Mobile number must be exactly 10 digits';
    }
    if (!_phoneRegExp.hasMatch(clean)) {
      return 'Number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  /// Validates standard email address format
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email address';
    }
    final clean = value.trim();
    if (!_emailRegExp.hasMatch(clean)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validates password (min 6 characters)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validates confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Validates user/parent name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter name';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
