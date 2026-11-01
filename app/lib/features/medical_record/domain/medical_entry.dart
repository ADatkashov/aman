import '../../../core/utils/localized_text.dart';

enum MedicalEntryType {
  visit,
  diagnosis,
  prescription,
  allergy,
  chronic,
  pastIllness,
  procedure,
  vaccination,
  lab,
  document;

  static MedicalEntryType fromId(String id) =>
      MedicalEntryType.values.firstWhere(
        (c) => c.name.toLowerCase() == id.toLowerCase().replaceAll('_', ''),
        orElse: () => MedicalEntryType.document,
      );
}

/// One confirmed item of the electronic medical record.
///
/// Every entry carries [sourceRef] — the appointment number or document that
/// confirms it. The app never creates medical facts by itself.
class MedicalEntry {
  const MedicalEntry({
    required this.id,
    required this.type,
    required this.date,
    required this.title,
    required this.sourceRef,
    this.details,
    this.doctorName,
  });

  final String id;
  final MedicalEntryType type;
  final DateTime date;
  final LocalizedText title;
  final LocalizedText? details;
  final String? doctorName;
  final String sourceRef;

  factory MedicalEntry.fromJson(Map<String, dynamic> json) => MedicalEntry(
    id: json['id'].toString(),
    type: MedicalEntryType.fromId(json['type'] as String),
    date: DateTime.parse(json['date'] as String),
    title: LocalizedText.fromJson(json['title']),
    details: json['details'] == null
        ? null
        : LocalizedText.fromJson(json['details']),
    doctorName: json['doctorName'] as String?,
    sourceRef: (json['sourceRef'] ?? '') as String,
  );
}
