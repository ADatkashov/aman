/// Kazakhstan (+7) phone number helpers.
abstract final class KzPhone {
  /// Returns the normalized `+7XXXXXXXXXX` form or `null` when the input is
  /// not a valid Kazakhstan / Russian numbering plan number.
  static String? normalize(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 11 && digits.startsWith('8')) {
      digits = '7${digits.substring(1)}';
    } else if (digits.length == 10) {
      digits = '7$digits';
    }
    if (digits.length != 11 || !digits.startsWith('7')) return null;
    // National significant numbers start with 3-9 (no 0,1,2 area codes).
    if ('012'.contains(digits[1])) return null;
    return '+$digits';
  }

  static bool isValid(String input) => normalize(input) != null;

  /// Formats `+77001234567` as `+7 700 123 45 67`.
  static String format(String normalized) {
    final d = normalized.replaceAll(RegExp(r'\D'), '');
    if (d.length != 11) return normalized;
    return '+7 ${d.substring(1, 4)} ${d.substring(4, 7)} ${d.substring(7, 9)} ${d.substring(9, 11)}';
  }

  /// Keeps only the national 10 digits typed by the user (for masked input).
  static String nationalDigits(String input) {
    var d = input.replaceAll(RegExp(r'\D'), '');
    // A country / trunk prefix is only present on full 11-digit input
    // (pasted "+7…" or "8…"); typed national numbers may start with 7.
    if (d.length >= 11 && (d.startsWith('7') || d.startsWith('8'))) d = d.substring(1);
    return d.length > 10 ? d.substring(0, 10) : d;
  }

  /// Formats up to 10 national digits progressively: `700 123 45 67`.
  static String maskNational(String digits) {
    final b = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 3 || i == 6 || i == 8) b.write(' ');
      b.write(digits[i]);
    }
    return b.toString();
  }
}
