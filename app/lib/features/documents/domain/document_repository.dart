import 'dart:typed_data';

import 'medical_document.dart';

abstract class DocumentRepository {
  Future<List<MedicalDocument>> list();
  Future<MedicalDocument> get(String id);

  /// Validates and stores a file. Throws [UploadException] on policy
  /// violations (empty file, > 10 MB, type other than PDF/JPG/PNG).
  Future<MedicalDocument> upload({
    required String fileName,
    required Uint8List bytes,
    required String title,
    DocumentKind kind = DocumentKind.other,
  });

  Future<void> delete(String id);
}
