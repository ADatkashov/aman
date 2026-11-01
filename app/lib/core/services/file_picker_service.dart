import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickedFile {
  const PickedFile({required this.name, required this.bytes});
  final String name;
  final Uint8List bytes;
}

/// File selection abstraction (overridden in tests).
abstract class FilePickerService {
  Future<PickedFile?> pickDocument();
}

class SystemFilePickerService implements FilePickerService {
  const SystemFilePickerService();

  @override
  Future<PickedFile?> pickDocument() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (files.isEmpty) return null;
    final file = files.first;
    final bytes = await file.readAsBytes();
    return PickedFile(name: file.name, bytes: bytes);
  }
}

final filePickerProvider = Provider<FilePickerService>(
  (ref) => const SystemFilePickerService(),
);
