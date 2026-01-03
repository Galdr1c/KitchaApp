/// Utility class for input validation and sanitization.
class InputValidator {
  static const int maxCommentLength = 500;
  static const int maxUsernameLength = 30;
  static const int minPasswordLength = 6;

  /// Validates email format.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email gerekli';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Geçerli bir email girin';
    }
    return null;
  }

  /// Validates password strength.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre gerekli';
    }
    if (value.length < minPasswordLength) {
      return 'Şifre en az $minPasswordLength karakter olmalı';
    }
    return null;
  }

  /// Validates username format.
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Kullanıcı adı gerekli';
    }
    if (value.length > maxUsernameLength) {
      return 'Kullanıcı adı maksimum $maxUsernameLength karakter olabilir';
    }
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Sadece harf, rakam ve _ kullanılabilir';
    }
    return null;
  }

  /// Sanitizes input to prevent XSS attacks.
  static String sanitize(String input) {
    return input
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }

  /// Validates comment content.
  static String? validateComment(String? value) {
    if (value == null || value.isEmpty) {
      return 'Yorum boş olamaz';
    }
    if (value.length > maxCommentLength) {
      return 'Yorum maksimum $maxCommentLength karakter olabilir';
    }

    // Basic profanity filter
    final badWords = ['spam', 'fake', 'scam'];
    for (var word in badWords) {
      if (value.toLowerCase().contains(word)) {
        return 'Uygunsuz içerik tespit edildi';
      }
    }

    return null;
  }

  /// Validates that a required field is not empty.
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName gerekli';
    }
    return null;
  }

  /// Validates a number is within a range.
  static String? validateNumberRange(
    int? value,
    String fieldName, {
    int? min,
    int? max,
  }) {
    if (value == null) {
      return '$fieldName gerekli';
    }
    if (min != null && value < min) {
      return '$fieldName en az $min olmalı';
    }
    if (max != null && value > max) {
      return '$fieldName en fazla $max olabilir';
    }
    return null;
  }
}
