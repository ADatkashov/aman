import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../catalog/domain/doctor.dart';
import '../../catalog/domain/specialty.dart';

/// State of the multi-step booking wizard.
class BookingDraft {
  const BookingDraft({
    this.specialty,
    this.doctor,
    this.date,
    this.slot,
    this.reason = '',
  });

  final Specialty? specialty;
  final Doctor? doctor;
  final DateTime? date;
  final DateTime? slot;
  final String reason;

  BookingDraft copyWith({
    Specialty? specialty,
    Doctor? doctor,
    DateTime? date,
    DateTime? slot,
    String? reason,
    bool clearSlot = false,
    bool clearDoctor = false,
  }) => BookingDraft(
    specialty: specialty ?? this.specialty,
    doctor: clearDoctor ? null : (doctor ?? this.doctor),
    date: date ?? this.date,
    slot: clearSlot ? null : (slot ?? this.slot),
    reason: reason ?? this.reason,
  );
}

class BookingDraftController extends Notifier<BookingDraft> {
  @override
  BookingDraft build() => const BookingDraft();

  /// Starts a new wizard session, optionally with pre-selected steps.
  void start({Specialty? specialty, Doctor? doctor, DateTime? slot}) =>
      state = BookingDraft(
        specialty: doctor?.specialty ?? specialty,
        doctor: doctor,
        date: slot == null ? null : DateTime(slot.year, slot.month, slot.day),
        slot: slot,
      );

  void pickSpecialty(Specialty s) {
    final keepDoctor = state.doctor?.specialty == s;
    state = state.copyWith(
      specialty: s,
      clearDoctor: !keepDoctor,
      clearSlot: !keepDoctor,
    );
  }

  void pickDoctor(Doctor d) => state = state.copyWith(
    doctor: d,
    specialty: d.specialty,
    clearSlot: true,
  );

  void pickDate(DateTime d) => state = state.copyWith(date: d, clearSlot: true);
  void pickSlot(DateTime s) => state = state.copyWith(slot: s);
  void setReason(String r) => state = state.copyWith(reason: r);
}

final bookingDraftProvider =
    NotifierProvider<BookingDraftController, BookingDraft>(
      BookingDraftController.new,
    );
