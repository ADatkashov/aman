import '../../../core/utils/localized_text.dart';

class ClinicService {
  const ClinicService({required this.name, required this.priceKzt});

  final LocalizedText name;
  final int priceKzt;

  factory ClinicService.fromJson(Map<String, dynamic> json) => ClinicService(
        name: LocalizedText.fromJson(json['name']),
        priceKzt: (json['priceKzt'] as num).toInt(),
      );
}

class Clinic {
  const Clinic({
    required this.id,
    required this.name,
    required this.city,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.rating,
    required this.reviewsCount,
    required this.workingHours,
    required this.services,
    required this.imageSeed,
    this.changeDeadlineHours = 2,
    this.isDemo = true,
  });

  final String id;
  final String name;
  final String city;
  final String address;
  final double latitude;
  final double longitude;
  final String phone;
  final double rating;
  final int reviewsCount;

  /// Human readable schedule, e.g. `Пн–Пт 08:00–20:00`.
  final LocalizedText workingHours;
  final List<ClinicService> services;

  /// Seed used to derive a deterministic cover illustration.
  final int imageSeed;

  /// Appointments can be cancelled / rescheduled only if the visit starts
  /// at least this many hours from now (clinic policy).
  final int changeDeadlineHours;
  final bool isDemo;

  String get fullAddress => '$city, $address';

  factory Clinic.fromJson(Map<String, dynamic> json) => Clinic(
        id: json['id'].toString(),
        name: json['name'] as String,
        city: json['city'] as String,
        address: json['address'] as String,
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        phone: json['phone'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewsCount: (json['reviewsCount'] as num).toInt(),
        workingHours: LocalizedText.fromJson(json['workingHours']),
        services: ((json['services'] ?? const []) as List)
            .map((e) => ClinicService.fromJson(e as Map<String, dynamic>))
            .toList(),
        imageSeed: (json['imageSeed'] as num?)?.toInt() ?? 0,
        changeDeadlineHours: (json['changeDeadlineHours'] as num?)?.toInt() ?? 2,
        isDemo: json['demo'] as bool? ?? false,
      );
}
