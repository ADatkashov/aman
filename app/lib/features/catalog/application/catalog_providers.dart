import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../features/settings/application/settings_providers.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/clinic.dart';
import '../domain/doctor.dart';
import '../domain/doctor_filter.dart';
import '../domain/specialty.dart';

final doctorsProvider = FutureProvider<List<Doctor>>(
  (ref) => ref.watch(catalogRepositoryProvider).doctors(),
);

final clinicsProvider = FutureProvider<List<Clinic>>(
  (ref) => ref.watch(catalogRepositoryProvider).clinics(),
);

final doctorProvider = FutureProvider.family<Doctor, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).doctor(id),
);

final clinicProvider = FutureProvider.family<Clinic, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).clinic(id),
);

final doctorReviewsProvider = FutureProvider.family<List<DoctorReview>, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).reviews(id),
);

typedef SlotsKey = ({String doctorId, DateTime date});

final slotsProvider = FutureProvider.autoDispose
    .family<List<TimeSlot>, SlotsKey>(
      (ref, key) =>
          ref.watch(catalogRepositoryProvider).slots(key.doctorId, key.date),
    );

final nextSlotProvider = FutureProvider.autoDispose.family<DateTime?, String>(
  (ref, doctorId) => ref.watch(catalogRepositoryProvider).nextSlot(doctorId),
);

class FavoritesController extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() {
    ref.watch(currentUserIdProvider);
    return ref.watch(catalogRepositoryProvider).favorites();
  }

  /// Returns `true` if the doctor is now a favorite.
  Future<bool> toggle(String doctorId) async {
    final updated = await ref
        .read(catalogRepositoryProvider)
        .toggleFavorite(doctorId);
    state = AsyncData(updated);
    return updated.contains(doctorId);
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesController, Set<String>>(
      FavoritesController.new,
    );

class DoctorFilterController extends Notifier<DoctorFilter> {
  @override
  DoctorFilter build() => DoctorFilter.empty;

  void set(DoctorFilter filter) => state = filter;
  void reset() => state = DoctorFilter.empty;
}

final doctorFilterProvider =
    NotifierProvider<DoctorFilterController, DoctorFilter>(
      DoctorFilterController.new,
    );

/// Doctors after search, filtering and sorting.
final filteredDoctorsProvider = Provider<AsyncValue<List<Doctor>>>((ref) {
  final filter = ref.watch(doctorFilterProvider);
  final locale = ref.watch(localeProvider);
  final favorites = ref.watch(favoritesProvider).value ?? const <String>{};
  final l10n = lookupAppL10n(locale);
  return ref
      .watch(doctorsProvider)
      .whenData(
        (doctors) => filter.apply(
          doctors,
          favorites: favorites,
          specialtyLabel: (Specialty s) => s.label(l10n),
        ),
      );
});

/// Clinics matching a free-text query (name / city / address).
List<Clinic> searchClinics(Iterable<Clinic> clinics, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return clinics.toList();
  return clinics
      .where(
        (c) => '${c.name} ${c.city} ${c.address}'.toLowerCase().contains(q),
      )
      .toList();
}

typedef ClinicLookup = Clinic? Function(String id);

/// Fast id → clinic lookup built from the loaded catalog.
final clinicLookupProvider = Provider<ClinicLookup>((ref) {
  final clinics = ref.watch(clinicsProvider).value ?? const <Clinic>[];
  final map = {for (final c in clinics) c.id: c};
  return (id) => map[id];
});

typedef DoctorLookup = Doctor? Function(String id);

final doctorLookupProvider = Provider<DoctorLookup>((ref) {
  final doctors = ref.watch(doctorsProvider).value ?? const <Doctor>[];
  final map = {for (final d in doctors) d.id: d};
  return (id) => map[id];
});
