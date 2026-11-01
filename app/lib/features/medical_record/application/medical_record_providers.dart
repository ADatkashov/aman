import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/medical_entry.dart';

final medicalEntriesProvider = FutureProvider<List<MedicalEntry>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(medicalRecordRepositoryProvider).entries();
});

/// Entries of [type] within an optional inclusive date range, newest first.
List<MedicalEntry> filterEntries(
  List<MedicalEntry> all, {
  MedicalEntryType? type,
  DateTime? from,
  DateTime? to,
}) {
  return all.where((e) {
    if (type != null && e.type != type) return false;
    if (from != null && e.date.isBefore(DateTime(from.year, from.month, from.day))) return false;
    if (to != null && e.date.isAfter(DateTime(to.year, to.month, to.day, 23, 59, 59))) return false;
    return true;
  }).toList()
    ..sort((a, b) => b.date.compareTo(a.date));
}
