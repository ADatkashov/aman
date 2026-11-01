import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../auth/application/auth_controller.dart';
import '../domain/medical_document.dart';

class DocumentsController extends AsyncNotifier<List<MedicalDocument>> {
  @override
  Future<List<MedicalDocument>> build() {
    ref.watch(currentUserIdProvider);
    return ref.watch(documentRepositoryProvider).list();
  }

  Future<void> _reload() async =>
      state = AsyncData(await ref.read(documentRepositoryProvider).list());

  Future<MedicalDocument> upload({
    required String fileName,
    required Uint8List bytes,
    required String title,
    required DocumentKind kind,
  }) async {
    final doc = await ref
        .read(documentRepositoryProvider)
        .upload(fileName: fileName, bytes: bytes, title: title, kind: kind);
    await _reload();
    return doc;
  }

  Future<void> delete(String id) async {
    await ref.read(documentRepositoryProvider).delete(id);
    await _reload();
  }
}

final documentsProvider =
    AsyncNotifierProvider<DocumentsController, List<MedicalDocument>>(
      DocumentsController.new,
    );

final documentProvider = FutureProvider.family<MedicalDocument, String>(
  (ref, id) => ref.watch(documentRepositoryProvider).get(id),
);
