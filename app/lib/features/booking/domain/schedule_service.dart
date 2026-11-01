import '../../../core/utils/formatters.dart';
import '../../catalog/domain/doctor.dart';

/// Pure scheduling rules shared by demo data and tests.
///
/// Slots are derived from the doctor's weekly working pattern; a slot is
/// available only if it lies in the future (with a lead time) and no active
/// appointment of the doctor already occupies it.
abstract final class ScheduleService {
  /// Minimum time between "now" and the start of a bookable slot.
  static const Duration leadTime = Duration(minutes: 30);

  /// Furthest day (from today) the patient may book.
  static const int bookingHorizonDays = 60;

  static List<DateTime> templateStarts(DoctorSchedule schedule, DateTime date) {
    if (!schedule.workDays.contains(date.weekday)) return const [];
    final day = Dates.dateOnly(date);
    final result = <DateTime>[];
    for (var m = schedule.startMinutes;
        m + schedule.slotMinutes <= schedule.endMinutes;
        m += schedule.slotMinutes) {
      final bs = schedule.breakStartMinutes;
      final be = schedule.breakEndMinutes;
      final overlapsBreak = bs != null && be != null && m < be && m + schedule.slotMinutes > bs;
      if (overlapsBreak) continue;
      result.add(day.add(Duration(minutes: m)));
    }
    return result;
  }

  static List<TimeSlot> slotsFor({
    required DoctorSchedule schedule,
    required DateTime date,
    required Set<DateTime> booked,
    required DateTime now,
  }) {
    final earliest = now.add(leadTime);
    return templateStarts(schedule, date)
        .map((s) => TimeSlot(
              start: s,
              available: s.isAfter(earliest) && !booked.contains(s),
            ))
        .toList();
  }

  /// Whether [start] is a slot the doctor actually offers (ignoring bookings).
  static bool isOfferedSlot(DoctorSchedule schedule, DateTime start) =>
      templateStarts(schedule, start).contains(start);

  static bool isWithinHorizon(DateTime date, DateTime now) {
    final diff = Dates.dateOnly(date).difference(Dates.dateOnly(now)).inDays;
    return diff >= 0 && diff <= bookingHorizonDays;
  }

  /// First available slot within [days] days, or `null`.
  static DateTime? nextAvailable({
    required DoctorSchedule schedule,
    required Set<DateTime> booked,
    required DateTime now,
    int days = 21,
  }) {
    for (var i = 0; i <= days; i++) {
      final date = Dates.dateOnly(now).add(Duration(days: i));
      for (final slot in slotsFor(schedule: schedule, date: date, booked: booked, now: now)) {
        if (slot.available) return slot.start;
      }
    }
    return null;
  }
}
