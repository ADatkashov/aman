import '../../catalog/domain/clinic.dart';

enum AppointmentStatus {
  confirmed,
  completed,
  cancelled;

  static AppointmentStatus fromId(String id) => AppointmentStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == id.toLowerCase(),
        orElse: () => AppointmentStatus.confirmed,
      );
}

class Appointment {
  const Appointment({
    required this.id,
    required this.number,
    required this.doctorId,
    required this.clinicId,
    required this.start,
    required this.durationMinutes,
    required this.status,
    required this.reason,
    required this.priceKzt,
    required this.createdAt,
    this.rescheduledCount = 0,
    this.cancelReason,
    this.reviewRating,
  });

  final String id;

  /// Human readable booking number, e.g. `AM-250522-0042`.
  final String number;
  final String doctorId;
  final String clinicId;
  final DateTime start;
  final int durationMinutes;
  final AppointmentStatus status;
  final String reason;
  final int priceKzt;
  final DateTime createdAt;
  final int rescheduledCount;
  final String? cancelReason;
  final int? reviewRating;

  DateTime get end => start.add(Duration(minutes: durationMinutes));

  bool isUpcoming(DateTime now) =>
      status == AppointmentStatus.confirmed && end.isAfter(now);

  /// Visits that were confirmed and whose time has already passed count as
  /// completed even if the clinic has not closed the record yet.
  bool isCompleted(DateTime now) =>
      status == AppointmentStatus.completed ||
      (status == AppointmentStatus.confirmed && !end.isAfter(now));

  /// Appointment can be cancelled or rescheduled according to clinic policy.
  bool canChange(Clinic clinic, DateTime now) =>
      status == AppointmentStatus.confirmed &&
      start.difference(now) >= Duration(hours: clinic.changeDeadlineHours);

  Appointment copyWith({
    DateTime? start,
    AppointmentStatus? status,
    String? cancelReason,
    int? rescheduledCount,
    int? reviewRating,
  }) =>
      Appointment(
        id: id,
        number: number,
        doctorId: doctorId,
        clinicId: clinicId,
        start: start ?? this.start,
        durationMinutes: durationMinutes,
        status: status ?? this.status,
        reason: reason,
        priceKzt: priceKzt,
        createdAt: createdAt,
        rescheduledCount: rescheduledCount ?? this.rescheduledCount,
        cancelReason: cancelReason ?? this.cancelReason,
        reviewRating: reviewRating ?? this.reviewRating,
      );

  factory Appointment.fromJson(Map<String, dynamic> json) => Appointment(
        id: json['id'].toString(),
        number: json['number'] as String,
        doctorId: json['doctorId'].toString(),
        clinicId: json['clinicId'].toString(),
        start: DateTime.parse(json['start'] as String).toLocal(),
        durationMinutes: (json['durationMinutes'] as num).toInt(),
        status: AppointmentStatus.fromId(json['status'] as String),
        reason: (json['reason'] ?? '') as String,
        priceKzt: (json['priceKzt'] as num).toInt(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
        rescheduledCount: (json['rescheduledCount'] as num?)?.toInt() ?? 0,
        cancelReason: json['cancelReason'] as String?,
        reviewRating: (json['reviewRating'] as num?)?.toInt(),
      );
}

/// Errors surfaced by booking operations. Messages are mapped to localized
/// strings in the presentation layer.
enum BookingFailure {
  slotTaken,
  slotInPast,
  outsideSchedule,
  tooLateToChange,
  notFound,
  reasonRequired,
  alreadyReviewed,
  notCompleted,
}

class BookingException implements Exception {
  const BookingException(this.failure);
  final BookingFailure failure;

  @override
  String toString() => 'BookingException(${failure.name})';
}
