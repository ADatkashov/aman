import 'package:aman/data/demo/demo_catalog_seed.dart';
import 'package:aman/features/catalog/domain/doctor_filter.dart';
import 'package:aman/features/catalog/domain/specialty.dart';
import 'package:flutter_test/flutter_test.dart';

String _label(Specialty s) => switch (s) {
      Specialty.therapist => 'Терапевт',
      Specialty.cardiologist => 'Кардиолог',
      _ => s.name,
    };

List<String> ids(DoctorFilter f, {Set<String> favorites = const {}}) =>
    f.apply(demoDoctors, favorites: favorites, specialtyLabel: _label).map((d) => d.id).toList();

void main() {
  test('demo catalog has the required volume and variety', () {
    expect(demoDoctors.length, inInclusiveRange(10, 15));
    expect(demoClinics.length, inInclusiveRange(5, 7));
    expect({for (final d in demoDoctors) d.specialty}.length, Specialty.values.length);
    expect(demoDoctors.every((d) => demoSchedules.containsKey(d.id)), isTrue);
    expect(demoClinics.every((c) => c.name.contains('DEMO')), isTrue);
  });

  test('search by name, surname part and specialty label', () {
    expect(ids(const DoctorFilter(query: 'смирнов')), ['d1']);
    expect(ids(const DoctorFilter(query: 'алексей иванович')), ['d1']);
    expect(ids(const DoctorFilter(query: 'кардиолог')).toSet(), {'d2', 'd10'});
    expect(ids(const DoctorFilter(query: 'zzz')), isEmpty);
  });

  test('filters by specialty, clinic, rating, price and experience', () {
    expect(ids(const DoctorFilter(specialty: Specialty.dentist)).toSet(), {'d6', 'd12'});
    expect(ids(const DoctorFilter(clinicId: 'c3')).toSet(), {'d3', 'd5', 'd11'});
    expect(ids(const DoctorFilter(minRating: 4.9)).toSet(), {'d1', 'd4', 'd5', 'd10'});
    expect(ids(const DoctorFilter(maxPriceKzt: 10000)).toSet(), {'d5', 'd9', 'd12'});
    expect(ids(const DoctorFilter(minExperience: 15)).toSet(), {'d2', 'd9', 'd10', 'd13'});
  });

  test('filters combine (AND)', () {
    final f = const DoctorFilter(specialty: Specialty.cardiologist, minRating: 4.9);
    expect(ids(f), ['d10']);
    expect(f.copyWith(clinicId: 'c1'), isA<DoctorFilter>());
    expect(ids(f.copyWith(clinicId: 'c1')), isEmpty);
  });

  test('sorting', () {
    final byPrice = const DoctorFilter(sort: DoctorSort.priceAsc).apply(demoDoctors, favorites: {}, specialtyLabel: _label);
    for (var i = 1; i < byPrice.length; i++) {
      expect(byPrice[i].priceKzt >= byPrice[i - 1].priceKzt, isTrue);
    }
    expect(ids(const DoctorFilter(sort: DoctorSort.priceDesc)).first, 'd10');
    expect(ids(const DoctorFilter(sort: DoctorSort.popularity)).first, 'd9');
    expect(ids(const DoctorFilter(sort: DoctorSort.experience)).first, 'd9');
    expect(ids(const DoctorFilter(sort: DoctorSort.rating)).first, anyOf('d5', 'd1', 'd4', 'd10'));
  });

  test('favorites only', () {
    expect(ids(const DoctorFilter(favoritesOnly: true), favorites: {'d2', 'd5'}).toSet(), {'d2', 'd5'});
    expect(ids(const DoctorFilter(favoritesOnly: true)), isEmpty);
  });

  test('copyWith can clear nullable filters', () {
    final f = const DoctorFilter(specialty: Specialty.dentist, minRating: 4.5).copyWith(specialty: null, minRating: null);
    expect(f.specialty, isNull);
    expect(f.minRating, isNull);
    expect(f.activeAdvancedCount, 0);
  });
}
