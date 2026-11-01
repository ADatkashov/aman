import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

import '../../core/utils/formatters.dart';
import '../../features/analyses/domain/lab_result.dart';
import '../../features/appointments/domain/appointment.dart';
import '../../features/auth/domain/patient_profile.dart';
import '../../features/booking/domain/schedule_service.dart';
import '../../features/catalog/domain/clinic.dart';
import '../../features/catalog/domain/doctor.dart';
import '../../features/documents/domain/medical_document.dart';
import '../../features/medical_record/domain/medical_entry.dart';
import '../../features/notifications/domain/app_notification.dart';
import 'demo_catalog_seed.dart';
import 'demo_patient_seed.dart';

class DemoAccountRecord {
  DemoAccountRecord({
    required this.profile,
    required this.salt,
    required this.passwordHash,
    this.verified = true,
  });

  PatientProfile profile;
  final String salt;
  String passwordHash;
  bool verified;
}

/// In-memory backend used in demo mode. It enforces the same business rules
/// as the real API (slot validation, no double booking, clinic change policy)
/// so that the UI behaves identically against either implementation.
class DemoStore {
  DemoStore({DateTime Function()? clock, this.latency = Duration.zero})
      : clock = clock ?? DateTime.now {
    final now = this.clock();
    _seed = PatientSeed(now);
    appointments = [..._seed.appointments];
    labs = [..._seed.labs];
    orders = [..._seed.orders];
    documents = [..._seed.documents];
    entries = [..._seed.entries];
    notifications = [..._seed.notifications];
    favorites = {..._seed.favorites};
    _foreignBookings = _generateForeignBookings(now);
    final demo = demoPatient();
    accounts[demo.phone] = DemoAccountRecord(
      profile: demo,
      salt: 'demo-salt',
      passwordHash: hashPassword(DemoAccount.password, 'demo-salt'),
    );
  }

  final DateTime Function() clock;

  /// Artificial delay so that loading states are visible in demo mode.
  final Duration latency;

  late final PatientSeed _seed;
  late List<Appointment> appointments;
  late List<LabResult> labs;
  late List<LabOrder> orders;
  late List<MedicalDocument> documents;
  late List<MedicalEntry> entries;
  late List<AppNotification> notifications;
  late Set<String> favorites;
  late final Map<String, Set<DateTime>> _foreignBookings;

  final Map<String, DemoAccountRecord> accounts = {};
  final Map<String, String> pendingOtps = {};

  final List<Clinic> clinics = demoClinics;
  final List<Doctor> doctors = demoDoctors;
  final Map<String, DoctorSchedule> schedules = demoSchedules;

  int _appointmentSeq = 100;
  int _idSeq = 1000;
  String? currentPatientId;

  Future<void> delay() => latency == Duration.zero ? Future.value() : Future.delayed(latency);

  String nextId(String prefix) => '$prefix${_idSeq++}';

  static String hashPassword(String password, String salt) =>
      sha256.convert(utf8.encode('$salt:$password')).toString();

  static String newSalt() {
    final r = Random.secure();
    return base64Url.encode(List.generate(12, (_) => r.nextInt(256)));
  }

  Doctor doctorById(String id) =>
      doctors.firstWhere((d) => d.id == id, orElse: () => throw const BookingException(BookingFailure.notFound));

  Clinic clinicById(String id) =>
      clinics.firstWhere((c) => c.id == id, orElse: () => throw const BookingException(BookingFailure.notFound));

  Appointment appointmentById(String id) => appointments.firstWhere((a) => a.id == id,
      orElse: () => throw const BookingException(BookingFailure.notFound));

  /// Start times of all active appointments of [doctorId], including those of
  /// other (simulated) patients.
  Set<DateTime> bookedStarts(String doctorId, {String? excludeAppointmentId}) {
    final own = appointments
        .where((a) =>
            a.doctorId == doctorId &&
            a.status == AppointmentStatus.confirmed &&
            a.id != excludeAppointmentId)
        .map((a) => a.start);
    return {...?_foreignBookings[doctorId], ...own};
  }

  List<TimeSlot> slots(String doctorId, DateTime date) {
    final schedule = schedules[doctorId];
    if (schedule == null) return const [];
    if (!ScheduleService.isWithinHorizon(date, clock())) return const [];
    return ScheduleService.slotsFor(
      schedule: schedule,
      date: date,
      booked: bookedStarts(doctorId),
      now: clock(),
    );
  }

  DateTime? nextSlot(String doctorId) {
    final schedule = schedules[doctorId];
    if (schedule == null) return null;
    return ScheduleService.nextAvailable(
      schedule: schedule,
      booked: bookedStarts(doctorId),
      now: clock(),
    );
  }

  /// Validates and books a slot atomically (no awaits between check and add).
  Appointment book({required String doctorId, required DateTime start, required String reason}) {
    if (reason.trim().length < 3) throw const BookingException(BookingFailure.reasonRequired);
    final doctor = doctorById(doctorId);
    final schedule = schedules[doctorId]!;
    final now = clock();
    if (!start.isAfter(now.add(ScheduleService.leadTime))) {
      throw const BookingException(BookingFailure.slotInPast);
    }
    if (!ScheduleService.isWithinHorizon(start, now) || !ScheduleService.isOfferedSlot(schedule, start)) {
      throw const BookingException(BookingFailure.outsideSchedule);
    }
    if (bookedStarts(doctorId).contains(start)) {
      throw const BookingException(BookingFailure.slotTaken);
    }
    final seq = _appointmentSeq++;
    final yy = (now.year % 100).toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    final appointment = Appointment(
      id: 'a$seq',
      number: 'AM-$yy$mm$dd-$seq',
      doctorId: doctorId,
      clinicId: doctor.clinicId,
      start: start,
      durationMinutes: schedule.slotMinutes,
      status: AppointmentStatus.confirmed,
      reason: reason.trim(),
      priceKzt: doctor.priceKzt,
      createdAt: now,
    );
    appointments = [appointment, ...appointments];
    pushNotification(
      NotificationType.appointmentCreated,
      {'doctor': doctor.shortName, 'start': start.toIso8601String(), 'number': appointment.number},
      '/appointments/${appointment.id}',
    );
    return appointment;
  }

  Appointment cancel(String id, {String? reason}) {
    final a = appointmentById(id);
    final clinic = clinicById(a.clinicId);
    if (!a.canChange(clinic, clock())) throw const BookingException(BookingFailure.tooLateToChange);
    final updated = a.copyWith(status: AppointmentStatus.cancelled, cancelReason: reason ?? '');
    _replace(updated);
    pushNotification(
      NotificationType.appointmentCancelled,
      {'doctor': doctorById(a.doctorId).shortName, 'start': a.start.toIso8601String(), 'number': a.number},
      '/appointments/${a.id}',
    );
    return updated;
  }

  Appointment reschedule(String id, DateTime newStart) {
    final a = appointmentById(id);
    final clinic = clinicById(a.clinicId);
    final now = clock();
    if (!a.canChange(clinic, now)) throw const BookingException(BookingFailure.tooLateToChange);
    final schedule = schedules[a.doctorId]!;
    if (!newStart.isAfter(now.add(ScheduleService.leadTime))) {
      throw const BookingException(BookingFailure.slotInPast);
    }
    if (!ScheduleService.isWithinHorizon(newStart, now) || !ScheduleService.isOfferedSlot(schedule, newStart)) {
      throw const BookingException(BookingFailure.outsideSchedule);
    }
    if (bookedStarts(a.doctorId, excludeAppointmentId: a.id).contains(newStart)) {
      throw const BookingException(BookingFailure.slotTaken);
    }
    final updated = a.copyWith(start: newStart, rescheduledCount: a.rescheduledCount + 1);
    _replace(updated);
    pushNotification(
      NotificationType.appointmentRescheduled,
      {'doctor': doctorById(a.doctorId).shortName, 'start': newStart.toIso8601String(), 'number': a.number},
      '/appointments/${a.id}',
    );
    return updated;
  }

  Appointment review(String id, int rating) {
    final a = appointmentById(id);
    if (!a.isCompleted(clock()) || a.status == AppointmentStatus.cancelled) {
      throw const BookingException(BookingFailure.notCompleted);
    }
    if (a.reviewRating != null) throw const BookingException(BookingFailure.alreadyReviewed);
    final updated = a.copyWith(reviewRating: rating.clamp(1, 5));
    _replace(updated);
    return updated;
  }

  void _replace(Appointment updated) {
    appointments = [for (final a in appointments) a.id == updated.id ? updated : a];
  }

  void pushNotification(NotificationType type, Map<String, String> params, String? route) {
    notifications = [
      AppNotification(
        id: nextId('n'),
        type: type,
        createdAt: clock(),
        params: params,
        route: route,
      ),
      ...notifications,
    ];
  }

  /// Deterministic pseudo-random occupancy by other patients.
  Map<String, Set<DateTime>> _generateForeignBookings(DateTime now) {
    final result = <String, Set<DateTime>>{};
    for (final d in demoDoctors) {
      final schedule = demoSchedules[d.id]!;
      final set = <DateTime>{};
      for (var day = 0; day <= 21; day++) {
        final date = Dates.dateOnly(now).add(Duration(days: day));
        final starts = ScheduleService.templateStarts(schedule, date);
        for (var i = 0; i < starts.length; i++) {
          final h = (d.avatarSeed * 31 + day * 17 + i * 13) % 100;
          if (h < 35) set.add(starts[i]);
        }
      }
      result[d.id] = set;
    }
    return result;
  }
}
