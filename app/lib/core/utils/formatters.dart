import 'package:intl/intl.dart';

/// Locale-aware formatting for money, dates and numbers.
class AmanFormat {
  AmanFormat(this.localeName);

  final String localeName;

  /// `12 000 ₸` (KZT, no fractional part).
  String money(num kzt) {
    final f = NumberFormat.currency(
      locale: localeName,
      symbol: '₸',
      decimalDigits: 0,
    );
    return f.format(kzt).replaceAll(' ', ' ');
  }

  String decimal(num value, {int digits = 1}) {
    final f = NumberFormat.decimalPatternDigits(
      locale: localeName,
      decimalDigits: digits,
    );
    return f.format(value);
  }

  /// Number with the minimum digits needed (no trailing zeros), max 2.
  String compact(num value) {
    final f = NumberFormat('#,##0.##', localeName);
    return f.format(value);
  }

  String time(DateTime d) => DateFormat.Hm(localeName).format(d);
  String dayMonth(DateTime d) => DateFormat.MMMMd(localeName).format(d);
  String dayMonthYear(DateTime d) => DateFormat.yMMMMd(localeName).format(d);
  String shortDate(DateTime d) => DateFormat.yMMMd(localeName).format(d);
  String weekdayShort(DateTime d) => DateFormat.E(localeName).format(d);
  String weekdayLong(DateTime d) => DateFormat.EEEE(localeName).format(d);
  String monthYear(DateTime d) => DateFormat.yMMMM(localeName).format(d);
  String dateTime(DateTime d) => '${dayMonth(d)}, ${time(d)}';
  String fullDateLine(DateTime d) => DateFormat.MMMMEEEEd(localeName).format(d);
}

/// Date helpers that do not depend on the locale.
abstract final class Dates {
  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
  static bool sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
