import 'dart:typed_data';

import '../../../core/utils/localized_text.dart';

enum DocumentKind {
  labReport,
  prescription,
  conclusion,
  referral,
  other;

  static DocumentKind fromId(String id) => DocumentKind.values.firstWhere(
    (c) => c.name.toLowerCase() == id.toLowerCase().replaceAll('_', ''),
    orElse: () => DocumentKind.other,
  );
}

class MedicalDocument {
  const MedicalDocument({
    required this.id,
    required this.title,
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    required this.uploadedAt,
    this.bytes,
    this.previewText,
    this.uploadedByPatient = false,
  });

  final String id;
  final String title;
  final DocumentKind kind;
  final String fileName;
  final String mimeType;
  final int sizeBytes;
  final DateTime uploadedAt;

  /// File contents, available for documents uploaded in this session.
  final Uint8List? bytes;

  /// Synthetic text rendered for demo documents.
  final LocalizedText? previewText;
  final bool uploadedByPatient;

  bool get isPdf => mimeType == 'application/pdf';
  bool get isImage => mimeType.startsWith('image/');

  factory MedicalDocument.fromJson(Map<String, dynamic> json) =>
      MedicalDocument(
        id: json['id'].toString(),
        title: json['title'] as String,
        kind: DocumentKind.fromId(json['kind'] as String),
        fileName: json['fileName'] as String,
        mimeType: json['mimeType'] as String,
        sizeBytes: (json['sizeBytes'] as num).toInt(),
        uploadedAt: DateTime.parse(json['uploadedAt'] as String),
        uploadedByPatient: json['uploadedByPatient'] as bool? ?? false,
      );
}

enum UploadFailure { empty, tooLarge, unsupportedType }

class UploadException implements Exception {
  const UploadException(this.failure);
  final UploadFailure failure;
}

/// Client-side upload policy; the backend enforces the same limits.
abstract final class DocumentPolicy {
  static const int maxBytes = 10 * 1024 * 1024;
  static const Map<String, String> allowed = {
    'pdf': 'application/pdf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
  };

  /// Returns the mime type for [fileName] or throws [UploadException].
  static String validate(String fileName, int sizeBytes) {
    if (sizeBytes <= 0) throw const UploadException(UploadFailure.empty);
    if (sizeBytes > maxBytes) {
      throw const UploadException(UploadFailure.tooLarge);
    }
    final dot = fileName.lastIndexOf('.');
    final ext = dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
    final mime = allowed[ext];
    if (mime == null) {
      throw const UploadException(UploadFailure.unsupportedType);
    }
    return mime;
  }
}
