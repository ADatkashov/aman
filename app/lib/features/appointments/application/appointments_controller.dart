import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../notifications/application/notifications_controller.dart';
import '../domain/appointment.dart';

/// All appointments of the patient plus the mutating use cases.
class AppointmentsController extends AsyncNotifier<List<Appointment>> {
  @override
  Future<List<Appointment>> build() {
    ref.watch(currentUserIdProvider);
    return ref.watch(appointmentRepositoryProvider).list();
  }

  Future<List<Appointment>> refresh() async {
    final list = await ref.read(appointmentRepositoryProvider).list();
    state = AsyncData(list);
    return list;
  }

  /// Local state is refreshed from the repository after every mutation so
  /// that it always mirrors the source of truth.
  Future<void> _afterChange() async {
    await refresh();
    ref.invalidate(notificationsProvider);
    ref.invalidate(slotsProvider);
    ref.invalidate(nextSlotProvider);
  }

  Future<Appointment> create({
    required String doctorId,
    required DateTime start,
    required String reason,
  }) async {
    final created = await ref
        .read(appointmentRepositoryProvider)
        .create(doctorId: doctorId, start: start, reason: reason);
    await _afterChange();
    return created;
  }

  Future<void> cancel(String id, {String? reason}) async {
    await ref.read(appointmentRepositoryProvider).cancel(id, reason: reason);
    await _afterChange();
  }

  Future<void> reschedule(String id, DateTime newStart) async {
    await ref.read(appointmentRepositoryProvider).reschedule(id, newStart);
    await _afterChange();
  }

  Future<void> review(String id, {required int rating, String? text}) async {
    await ref
        .read(appointmentRepositoryProvider)
        .review(id, rating: rating, text: text);
    await refresh();
  }
}

final appointmentsProvider =
    AsyncNotifierProvider<AppointmentsController, List<Appointment>>(
      AppointmentsController.new,
    );

final appointmentProvider = Provider.family<AsyncValue<Appointment>, String>((
  ref,
  id,
) {
  return ref
      .watch(appointmentsProvider)
      .whenData(
        (list) => list.firstWhere(
          (a) => a.id == id,
          orElse: () => throw const BookingException(BookingFailure.notFound),
        ),
      );
});

/// The nearest confirmed future visit, if any.
final nextAppointmentProvider = Provider<AsyncValue<Appointment?>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref.watch(appointmentsProvider).whenData((list) {
    final upcoming = list.where((a) => a.isUpcoming(now)).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return upcoming.isEmpty ? null : upcoming.first;
  });
});

enum AppointmentTab { upcoming, completed, cancelled }

enum AppointmentPeriod { all, days30, days90, days365 }

extension AppointmentPeriodX on AppointmentPeriod {
  int? get days => switch (this) {
    AppointmentPeriod.all => null,
    AppointmentPeriod.days30 => 30,
    AppointmentPeriod.days90 => 90,
    AppointmentPeriod.days365 => 365,
  };
}

/// Pure grouping/filtering used by the "My appointments" screen (unit-tested).
List<Appointment> selectAppointments(
  List<Appointment> all, {
  required AppointmentTab tab,
  required AppointmentPeriod period,
  required DateTime now,
}) {
  var list = all.where((a) {
    switch (tab) {
      case AppointmentTab.upcoming:
        return a.isUpcoming(now);
      case AppointmentTab.completed:
        return a.isCompleted(now) && a.status != AppointmentStatus.cancelled;
      case AppointmentTab.cancelled:
        return a.status == AppointmentStatus.cancelled;
    }
  });
  final days = period.days;
  if (days != null) {
    final from = now.subtract(Duration(days: days));
    final to = now.add(Duration(days: days));
    list = list.where((a) => a.start.isAfter(from) && a.start.isBefore(to));
  }
  final result = list.toList();
  result.sort(
    (a, b) => tab == AppointmentTab.upcoming
        ? a.start.compareTo(b.start)
        : b.start.compareTo(a.start),
  );
  return result;
}
