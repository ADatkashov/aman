import 'clinic.dart';
import 'doctor.dart';

abstract class CatalogRepository {
  Future<List<Doctor>> doctors();
  Future<Doctor> doctor(String id);
  Future<List<Clinic>> clinics();
  Future<Clinic> clinic(String id);
  Future<List<DoctorReview>> reviews(String doctorId);

  /// All slots of [date] with their availability.
  Future<List<TimeSlot>> slots(String doctorId, DateTime date);

  /// Earliest free slot in the coming weeks, if any.
  Future<DateTime?> nextSlot(String doctorId);

  Future<Set<String>> favorites();

  /// Toggles the doctor and returns the updated favorites.
  Future<Set<String>> toggleFavorite(String doctorId);
}
