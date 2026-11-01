import 'appointment.dart';

abstract class AppointmentRepository {
  Future<List<Appointment>> list();
  Future<Appointment> get(String id);

  /// Books a slot. Throws [BookingException] with
  /// [BookingFailure.slotTaken] if it was booked in the meantime.
  Future<Appointment> create({
    required String doctorId,
    required DateTime start,
    required String reason,
  });

  Future<Appointment> cancel(String id, {String? reason});
  Future<Appointment> reschedule(String id, DateTime newStart);
  Future<Appointment> review(String id, {required int rating, String? text});
}
