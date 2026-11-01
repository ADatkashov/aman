import 'doctor.dart';
import 'specialty.dart';

enum DoctorSort { popularity, rating, priceAsc, priceDesc, experience }

/// Immutable description of the doctor catalog query.
class DoctorFilter {
  const DoctorFilter({
    this.query = '',
    this.specialty,
    this.clinicId,
    this.minRating,
    this.maxPriceKzt,
    this.minExperience,
    this.sort = DoctorSort.popularity,
    this.favoritesOnly = false,
  });

  final String query;
  final Specialty? specialty;
  final String? clinicId;
  final double? minRating;
  final int? maxPriceKzt;
  final int? minExperience;
  final DoctorSort sort;
  final bool favoritesOnly;

  static const empty = DoctorFilter();

  /// Number of active "advanced" filters (used for the filter badge).
  int get activeAdvancedCount =>
      (clinicId != null ? 1 : 0) +
      (minRating != null ? 1 : 0) +
      (maxPriceKzt != null ? 1 : 0) +
      (minExperience != null ? 1 : 0);

  DoctorFilter copyWith({
    String? query,
    Object? specialty = _keep,
    Object? clinicId = _keep,
    Object? minRating = _keep,
    Object? maxPriceKzt = _keep,
    Object? minExperience = _keep,
    DoctorSort? sort,
    bool? favoritesOnly,
  }) =>
      DoctorFilter(
        query: query ?? this.query,
        specialty: identical(specialty, _keep) ? this.specialty : specialty as Specialty?,
        clinicId: identical(clinicId, _keep) ? this.clinicId : clinicId as String?,
        minRating: identical(minRating, _keep) ? this.minRating : minRating as double?,
        maxPriceKzt: identical(maxPriceKzt, _keep) ? this.maxPriceKzt : maxPriceKzt as int?,
        minExperience:
            identical(minExperience, _keep) ? this.minExperience : minExperience as int?,
        sort: sort ?? this.sort,
        favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      );

  static const Object _keep = Object();

  /// Applies the filter and sorting. [specialtyLabel] resolves the localized
  /// specialty name so that the search box also matches it.
  List<Doctor> apply(
    Iterable<Doctor> doctors, {
    required Set<String> favorites,
    required String Function(Specialty) specialtyLabel,
  }) {
    final q = query.trim().toLowerCase();
    final result = doctors.where((d) {
      if (specialty != null && d.specialty != specialty) return false;
      if (clinicId != null && d.clinicId != clinicId) return false;
      if (minRating != null && d.rating < minRating!) return false;
      if (maxPriceKzt != null && d.priceKzt > maxPriceKzt!) return false;
      if (minExperience != null && d.experienceYears < minExperience!) return false;
      if (favoritesOnly && !favorites.contains(d.id)) return false;
      if (q.isNotEmpty) {
        final hay = '${d.fullName} ${specialtyLabel(d.specialty)}'.toLowerCase();
        if (!q.split(RegExp(r'\s+')).every(hay.contains)) return false;
      }
      return true;
    }).toList();

    int cmp(Doctor a, Doctor b) {
      switch (sort) {
        case DoctorSort.popularity:
          return b.reviewsCount.compareTo(a.reviewsCount);
        case DoctorSort.rating:
          final r = b.rating.compareTo(a.rating);
          return r != 0 ? r : b.reviewsCount.compareTo(a.reviewsCount);
        case DoctorSort.priceAsc:
          return a.priceKzt.compareTo(b.priceKzt);
        case DoctorSort.priceDesc:
          return b.priceKzt.compareTo(a.priceKzt);
        case DoctorSort.experience:
          return b.experienceYears.compareTo(a.experienceYears);
      }
    }

    result.sort((a, b) {
      final c = cmp(a, b);
      return c != 0 ? c : a.fullName.compareTo(b.fullName);
    });
    return result;
  }
}
