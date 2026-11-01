import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/lab_result.dart';

final labResultsProvider = FutureProvider<List<LabResult>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(labRepositoryProvider).results();
});

final labOrdersProvider = FutureProvider<List<LabOrder>>((ref) {
  ref.watch(currentUserIdProvider);
  return ref.watch(labRepositoryProvider).orders();
});

final labResultProvider = FutureProvider.family<LabResult, String>(
  (ref, id) => ref.watch(labRepositoryProvider).result(id),
);

/// Series of (date, value) for the first indicator of [result]'s test type,
/// oldest first. Used for the dynamics chart.
List<LabTrendPoint> trendFor(
  List<LabResult> all,
  LabResult result,
  int indicatorIndex,
) {
  if (indicatorIndex >= result.indicators.length) return const [];
  final points = <LabTrendPoint>[];
  for (final r in all.where(
    (r) => r.testCode == result.testCode && r.hasValues,
  )) {
    if (indicatorIndex < r.indicators.length) {
      points.add(LabTrendPoint(r.date, r.indicators[indicatorIndex].value));
    }
  }
  points.sort((a, b) => a.date.compareTo(b.date));
  return points;
}

class LabTrendPoint {
  const LabTrendPoint(this.date, this.value);
  final DateTime date;
  final double value;
}
