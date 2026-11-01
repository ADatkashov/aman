import 'package:aman/features/booking/domain/schedule_service.dart';
import 'package:aman/features/catalog/domain/doctor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Mon–Fri 09:00–12:00 + 14:00–16:00 with a 12:00–14:00 break, 30-min slots.
  const schedule = DoctorSchedule(
    doctorId: 'dX',
    workDays: {1, 2, 3, 4, 5},
    startMinutes: 540,
    endMinutes: 960,
    slotMinutes: 30,
    breakStartMinutes: 720,
    breakEndMinutes: 840,
  );
  final monday = DateTime(2026, 11, 2);
  final saturday = DateTime(2026, 11, 7);

  test('generates slots only inside working hours and skips the break', () {
    final starts = ScheduleService.templateStarts(schedule, monday);
    expect(starts.first, DateTime(2026, 11, 2, 9, 0));
    expect(starts.last, DateTime(2026, 11, 2, 15, 30));
    expect(starts.any((s) => s.hour == 12 || s.hour == 13), isFalse);
    expect(starts.length, 6 + 4);
  });

  test('no slots on non working days', () {
    expect(ScheduleService.templateStarts(schedule, saturday), isEmpty);
  });

  test('slots in the past or within lead time are unavailable', () {
    final now = DateTime(2026, 11, 2, 10, 0);
    final slots = ScheduleService.slotsFor(schedule: schedule, date: monday, booked: {}, now: now);
    final byTime = {for (final s in slots) s.start: s.available};
    expect(byTime[DateTime(2026, 11, 2, 9, 30)], isFalse);
    expect(byTime[DateTime(2026, 11, 2, 10, 0)], isFalse);
    expect(byTime[DateTime(2026, 11, 2, 10, 30)], isFalse, reason: 'exactly at now+30m is not bookable');
    expect(byTime[DateTime(2026, 11, 2, 11, 0)], isTrue);
  });

  test('booked slots are unavailable', () {
    final booked = {DateTime(2026, 11, 2, 11, 0)};
    final slots = ScheduleService.slotsFor(
      schedule: schedule,
      date: monday,
      booked: booked,
      now: DateTime(2026, 11, 2, 8, 0),
    );
    expect(slots.firstWhere((s) => s.start.hour == 11 && s.start.minute == 0).available, isFalse);
    expect(slots.firstWhere((s) => s.start.hour == 11 && s.start.minute == 30).available, isTrue);
  });

  test('nextAvailable skips fully booked days', () {
    final all = ScheduleService.templateStarts(schedule, monday).toSet();
    final next = ScheduleService.nextAvailable(
      schedule: schedule,
      booked: all,
      now: DateTime(2026, 11, 2, 8, 0),
    );
    expect(next, DateTime(2026, 11, 3, 9, 0));
  });

  test('isOfferedSlot rejects misaligned and break times', () {
    expect(ScheduleService.isOfferedSlot(schedule, DateTime(2026, 11, 2, 9, 30)), isTrue);
    expect(ScheduleService.isOfferedSlot(schedule, DateTime(2026, 11, 2, 9, 15)), isFalse);
    expect(ScheduleService.isOfferedSlot(schedule, DateTime(2026, 11, 2, 12, 30)), isFalse);
    expect(ScheduleService.isOfferedSlot(schedule, DateTime(2026, 11, 7, 10, 0)), isFalse);
  });

  test('booking horizon', () {
    final now = DateTime(2026, 11, 2, 9);
    expect(ScheduleService.isWithinHorizon(DateTime(2026, 11, 2), now), isTrue);
    expect(ScheduleService.isWithinHorizon(DateTime(2026, 11, 1), now), isFalse);
    expect(ScheduleService.isWithinHorizon(DateTime(2027, 2, 1), now), isFalse);
  });
}
