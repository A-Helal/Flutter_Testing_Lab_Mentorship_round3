/// Utility class for form validation
class Validation {
  /// Email validation using regex: ^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Password validation
  /// Password must have:
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one number
  /// - At least one special character
  static bool isValidPassword(String password) {
    if (password.length < 8) return false;

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasNumber = RegExp(r'[0-9]').hasMatch(password);
    final hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return hasUppercase && hasNumber && hasSpecialChar;
  }
}

