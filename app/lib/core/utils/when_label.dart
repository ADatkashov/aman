import '../l10n/l10n_ext.dart';
import 'formatters.dart';

/// "Today, 10:30" / "Tomorrow, 10:30" / "12 May, 10:30".
String whenLabel(AppL10n l, AmanFormat fmt, DateTime d, DateTime now) {
  final days = Dates.dateOnly(d).difference(Dates.dateOnly(now)).inDays;
  final time = fmt.time(d);
  if (days == 0) return '${l.today}, $time';
  if (days == 1) return '${l.tomorrow}, $time';
  return '${fmt.dayMonth(d)}, $time';
}
