import 'lab_result.dart';

abstract class LabRepository {
  Future<List<LabResult>> results();
  Future<LabResult> result(String id);
  Future<List<LabOrder>> orders();
}
