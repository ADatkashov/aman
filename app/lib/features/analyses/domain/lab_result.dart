import '../../../core/utils/localized_text.dart';

enum LabCategory {
  cbc,
  biochemistry,
  urine,
  hormones,
  vitamins,
  immunology,
  pcr,
  other;

  static LabCategory fromId(String id) => LabCategory.values.firstWhere(
        (c) => c.name == id,
        orElse: () => LabCategory.other,
      );
}

enum LabStatus {
  pending,
  processing,
  ready,
  attention;

  static LabStatus fromId(String id) => LabStatus.values.firstWhere(
        (c) => c.name.toLowerCase() == id.toLowerCase(),
        orElse: () => LabStatus.pending,
      );
}

/// A single measured value together with the reference interval supplied by
/// the laboratory. The app never interprets values on its own: it only
/// reports whether a value lies outside the laboratory's interval.
class LabIndicator {
  const LabIndicator({
    required this.name,
    required this.value,
    required this.unit,
    this.refMin,
    this.refMax,
  });

  final LocalizedText name;
  final double value;
  final String unit;
  final double? refMin;
  final double? refMax;

  bool get hasReference => refMin != null || refMax != null;

  bool get isOutOfRange =>
      (refMin != null && value < refMin!) || (refMax != null && value > refMax!);

  factory LabIndicator.fromJson(Map<String, dynamic> json) => LabIndicator(
        name: LocalizedText.fromJson(json['name']),
        value: (json['value'] as num).toDouble(),
        unit: json['unit'] as String,
        refMin: (json['refMin'] as num?)?.toDouble(),
        refMax: (json['refMax'] as num?)?.toDouble(),
      );
}

class LabResult {
  const LabResult({
    required this.id,
    required this.testCode,
    required this.category,
    required this.name,
    required this.date,
    required this.laboratory,
    required this.status,
    this.indicators = const [],
    this.documentId,
  });

  final String id;

  /// Stable code of the test type; results with equal codes form a trend.
  final String testCode;
  final LabCategory category;
  final LocalizedText name;
  final DateTime date;
  final String laboratory;
  final LabStatus status;
  final List<LabIndicator> indicators;
  final String? documentId;

  bool get hasValues => indicators.isNotEmpty;

  factory LabResult.fromJson(Map<String, dynamic> json) => LabResult(
        id: json['id'].toString(),
        testCode: json['testCode'] as String,
        category: LabCategory.fromId(json['category'] as String),
        name: LocalizedText.fromJson(json['name']),
        date: DateTime.parse(json['date'] as String),
        laboratory: json['laboratory'] as String,
        status: LabStatus.fromId(json['status'] as String),
        indicators: ((json['indicators'] ?? const []) as List)
            .map((e) => LabIndicator.fromJson(e as Map<String, dynamic>))
            .toList(),
        documentId: json['documentId']?.toString(),
      );
}

/// A laboratory test prescribed by a doctor that has not been resulted yet.
class LabOrder {
  const LabOrder({
    required this.id,
    required this.name,
    required this.category,
    required this.doctorName,
    required this.date,
    required this.status,
  });

  final String id;
  final LocalizedText name;
  final LabCategory category;
  final String doctorName;
  final DateTime date;
  final LabStatus status;
}
