import 'phone.dart';

/// Validation error codes; UI maps them to localized messages.
enum FieldError {
  required,
  invalidPhone,
  weakPassword,
  invalidEmail,
  invalidOtp,
  nameTooShort,
  passwordMismatch,
  invalidDate,
  reasonTooShort,
}

/// Pure validators returning `null` when the value is valid.
abstract final class Validators {
  static FieldError? required(String? v) =>
      (v == null || v.trim().isEmpty) ? FieldError.required : null;

  static FieldError? phone(String? v) {
    if (v == null || v.trim().isEmpty) return FieldError.required;
    return KzPhone.isValid(v) ? null : FieldError.invalidPhone;
  }

  /// At least 8 characters with a letter and a digit.
  static FieldError? password(String? v) {
    if (v == null || v.isEmpty) return FieldError.required;
    final ok = v.length >= 8 && RegExp(r'[A-Za-zА-Яа-яЁёӘәҒғҚқҢңӨөҰұҮүҺһІі]').hasMatch(v) && RegExp(r'\d').hasMatch(v);
    return ok ? null : FieldError.weakPassword;
  }

  static FieldError? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) return FieldError.required;
    return v == original ? null : FieldError.passwordMismatch;
  }

  static FieldError? fullName(String? v) {
    if (v == null || v.trim().isEmpty) return FieldError.required;
    final parts = v.trim().split(RegExp(r'\s+'));
    return (parts.length >= 2 && parts.every((p) => p.length >= 2)) ? null : FieldError.nameTooShort;
  }

  static FieldError? optionalEmail(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$').hasMatch(v.trim());
    return ok ? null : FieldError.invalidEmail;
  }

  static FieldError? otp(String? v) {
    if (v == null || v.isEmpty) return FieldError.required;
    return RegExp(r'^\d{4}$').hasMatch(v) ? null : FieldError.invalidOtp;
  }

  static FieldError? reason(String? v) {
    if (v == null || v.trim().isEmpty) return FieldError.required;
    return v.trim().length >= 3 ? null : FieldError.reasonTooShort;
  }
}
