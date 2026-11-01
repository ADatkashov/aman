import '../../../core/utils/localized_text.dart';
import 'clinic.dart';
import 'specialty.dart';

class Doctor {
  const Doctor({
    required this.id,
    required this.fullName,
    required this.specialty,
    required this.clinicId,
    required this.experienceYears,
    required this.rating,
    required this.reviewsCount,
    required this.priceKzt,
    required this.education,
    required this.qualification,
    required this.about,
    required this.languages,
    required this.services,
    required this.avatarSeed,
    this.isFemale = false,
    this.photoUrl,
  });

  final String id;
  final String fullName;
  final Specialty specialty;
  final String clinicId;
  final int experienceYears;
  final double rating;
  final int reviewsCount;
  final int priceKzt;
  final LocalizedText education;
  final LocalizedText qualification;
  final LocalizedText about;

  /// ISO language codes the doctor speaks (kk, ru, en).
  final List<String> languages;
  final List<ClinicService> services;
  final int avatarSeed;
  final bool isFemale;

  /// Optional professional photo. When absent an illustrated avatar is drawn.
  final String? photoUrl;

  /// "Surname N." short form used in compact cards.
  String get shortName {
    final parts = fullName.split(' ');
    if (parts.length < 2) return fullName;
    return '${parts[0]} ${parts[1][0]}.';
  }

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
    id: json['id'].toString(),
    fullName: json['fullName'] as String,
    specialty: Specialty.fromId(json['specialty'] as String),
    clinicId: json['clinicId'].toString(),
    experienceYears: (json['experienceYears'] as num).toInt(),
    rating: (json['rating'] as num).toDouble(),
    reviewsCount: (json['reviewsCount'] as num).toInt(),
    priceKzt: (json['priceKzt'] as num).toInt(),
    education: LocalizedText.fromJson(json['education']),
    qualification: LocalizedText.fromJson(json['qualification']),
    about: LocalizedText.fromJson(json['about']),
    languages: ((json['languages'] ?? const []) as List).cast<String>(),
    services: ((json['services'] ?? const []) as List)
        .map((e) => ClinicService.fromJson(e as Map<String, dynamic>))
        .toList(),
    avatarSeed: (json['avatarSeed'] as num?)?.toInt() ?? 0,
    isFemale: json['female'] as bool? ?? false,
    photoUrl: json['photoUrl'] as String?,
  );
}

/// Recurring weekly working pattern of a doctor.
class DoctorSchedule {
  const DoctorSchedule({
    required this.doctorId,
    required this.workDays,
    required this.startMinutes,
    required this.endMinutes,
    required this.slotMinutes,
    this.breakStartMinutes,
    this.breakEndMinutes,
  });

  final String doctorId;

  /// [DateTime.weekday] values (1 = Monday … 7 = Sunday).
  final Set<int> workDays;
  final int startMinutes;
  final int endMinutes;
  final int slotMinutes;
  final int? breakStartMinutes;
  final int? breakEndMinutes;
}

class TimeSlot {
  const TimeSlot({required this.start, required this.available});

  final DateTime start;
  final bool available;

  factory TimeSlot.fromJson(Map<String, dynamic> json) => TimeSlot(
    start: DateTime.parse(json['start'] as String).toLocal(),
    available: json['available'] as bool,
  );
}

class DoctorReview {
  const DoctorReview({
    required this.id,
    required this.doctorId,
    required this.author,
    required this.rating,
    required this.text,
    required this.date,
  });

  final String id;
  final String doctorId;
  final String author;
  final int rating;
  final String text;
  final DateTime date;

  factory DoctorReview.fromJson(Map<String, dynamic> json) => DoctorReview(
    id: json['id'].toString(),
    doctorId: json['doctorId'].toString(),
    author: json['author'] as String,
    rating: (json['rating'] as num).toInt(),
    text: json['text'] as String,
    date: DateTime.parse(json['date'] as String),
  );
}
