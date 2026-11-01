import 'package:aman/data/demo/demo_store.dart';
import 'package:aman/features/appointments/domain/appointment.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

/// Business rules of the (demo) backend: no double booking, clinic change
/// policy, validation. The same rules are enforced by the Spring service.
void main() {
  late DemoStore store;
  // d1: Mon–Fri 09:00–18:00, 30-min slots, break 13:00–14:00.
  final slot = DateTime(2026, 11, 4, 15, 0); // Wednesday 15:00

  setUp(() => store = newStore());

  Matcher failsWith(BookingFailure f) =>
      throwsA(isA<BookingException>().having((e) => e.failure, 'failure', f));

  DateTime freeSlot(String doctor) {
    final slots = store.slots(doctor, DateTime(2026, 11, 5));
    return slots.firstWhere((s) => s.available).start;
  }

  test('creates an appointment with a unique number and a notification', () {
    final s = freeSlot('d1');
    final before = store.notifications.length;
    final a = store.book(doctorId: 'd1', start: s, reason: 'Check-up');
    expect(a.status, AppointmentStatus.confirmed);
    expect(a.number, startsWith('AM-'));
    final b = store.book(doctorId: 'd9', start: freeSlot('d9'), reason: 'Check-up');
    expect(b.number, isNot(a.number));
    expect(store.notifications.length, before + 2);
  });

  test('double booking of the same slot is rejected', () {
    final s = freeSlot('d1');
    store.book(doctorId: 'd1', start: s, reason: 'First');
    expect(() => store.book(doctorId: 'd1', start: s, reason: 'Second'), failsWith(BookingFailure.slotTaken));
  });

  test('a slot becomes free again after cancellation', () {
    final s = freeSlot('d1');
    final a = store.book(doctorId: 'd1', start: s, reason: 'First');
    store.cancel(a.id);
    expect(store.slots('d1', DateTime(s.year, s.month, s.day)).firstWhere((x) => x.start == s).available, isTrue);
    expect(() => store.book(doctorId: 'd1', start: s, reason: 'Again'), returnsNormally);
  });

  test('rejects slots outside the doctor schedule, in the past and without reason', () {
    expect(() => store.book(doctorId: 'd1', start: DateTime(2026, 11, 4, 13, 0), reason: 'Lunch'),
        failsWith(BookingFailure.outsideSchedule));
    expect(() => store.book(doctorId: 'd1', start: DateTime(2026, 11, 7, 10, 0), reason: 'Saturday'),
        failsWith(BookingFailure.outsideSchedule));
    expect(() => store.book(doctorId: 'd1', start: DateTime(2026, 11, 2, 9, 0), reason: 'Past'),
        failsWith(BookingFailure.slotInPast));
    expect(() => store.book(doctorId: 'd1', start: slot, reason: ' '), failsWith(BookingFailure.reasonRequired));
  });

  test('cancel works before the clinic deadline and fails after', () {
    final far = store.book(doctorId: 'd1', start: freeSlot('d1'), reason: 'Visit');
    final cancelled = store.cancel(far.id, reason: 'Plans changed');
    expect(cancelled.status, AppointmentStatus.cancelled);
    expect(cancelled.cancelReason, 'Plans changed');

    // Seeded upcoming visit moved to 1h from now violates the 2h policy.
    final near = (store.appointments).first.copyWith(start: testNow.add(const Duration(hours: 1)));
    store.appointments = [near, ...store.appointments.skip(1)];
    expect(() => store.cancel(near.id), failsWith(BookingFailure.tooLateToChange));
    expect(() => store.reschedule(near.id, freeSlot('d1')), failsWith(BookingFailure.tooLateToChange));
  });

  test('reschedule moves the visit, frees the old slot and blocks taken slots', () {
    final first = store.book(doctorId: 'd1', start: freeSlot('d1'), reason: 'Visit');
    final slots = store.slots('d1', DateTime(2026, 11, 6));
    final target = slots.firstWhere((s) => s.available).start;
    final moved = store.reschedule(first.id, target);
    expect(moved.start, target);
    expect(moved.rescheduledCount, 1);
    // old slot is free, new slot is taken
    expect(store.bookedStarts('d1').contains(first.start), isFalse);
    final other = store.book(doctorId: 'd1', start: freeSlot('d1'), reason: 'Other');
    expect(() => store.reschedule(other.id, target), failsWith(BookingFailure.slotTaken));
  });

  test('review only after completion and only once', () {
    final upcoming = (store.appointments).first;
    expect(() => store.review(upcoming.id, 5), failsWith(BookingFailure.notCompleted));
    final completed = (store.appointments).firstWhere(
      (a) => a.status == AppointmentStatus.completed && a.reviewRating == null,
    );
    final reviewed = store.review(completed.id, 9);
    expect(reviewed.reviewRating, 5, reason: 'rating is clamped to 1..5');
    expect(() => store.review(completed.id, 4), failsWith(BookingFailure.alreadyReviewed));
  });

  test('unknown ids are reported as notFound', () {
    expect(() => store.cancel('nope'), failsWith(BookingFailure.notFound));
    expect(() => store.doctorById('nope'), failsWith(BookingFailure.notFound));
  });

  test('concurrent bookings of one slot: exactly one wins', () async {
    final s = freeSlot('d1');
    final results = await Future.wait([
      for (var i = 0; i < 5; i++)
        Future(() => store.book(doctorId: 'd1', start: s, reason: 'Race $i'))
            .then<Object>((a) => a as Object)
            .catchError((Object e) => e),
    ]);
    expect(results.whereType<Appointment>().length, 1);
    expect(results.whereType<BookingException>().length, 4);
  });
}
