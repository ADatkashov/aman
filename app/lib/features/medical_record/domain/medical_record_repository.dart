import 'medical_entry.dart';

abstract class MedicalRecordRepository {
  Future<List<MedicalEntry>> entries();
}
