import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/file_picker_service.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../application/documents_controller.dart';
import '../domain/medical_document.dart';

IconData docIcon(MedicalDocument d) => d.isPdf
    ? Icons.picture_as_pdf_rounded
    : d.isImage
        ? Icons.image_rounded
        : Icons.description_rounded;

String formatSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
  return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
}

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final docs = ref.watch(documentsProvider);
    return Scaffold(
      appBar: CustomAppBar(
        title: l.documentsTitle,
        actions: [
          AmanIconButton(
            icon: Icons.upload_file_rounded,
            tooltip: l.uploadDocument,
            color: p.primary,
            onPressed: () => showUploadSheet(context),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(documentsProvider);
          await ref.read(documentsProvider.future);
        },
        child: AsyncBody<List<MedicalDocument>>(
          value: docs,
          onRetry: () => ref.invalidate(documentsProvider),
          builder: (list) {
            if (list.isEmpty) {
              return ListView(children: [
                const SizedBox(height: 40),
                EmptyState(
                  icon: Icons.folder_open_rounded,
                  title: l.noDocumentsTitle,
                  body: l.noDocumentsBody,
                  actionLabel: l.uploadDocument,
                  onAction: () => showUploadSheet(context),
                ),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final d = list[i];
                return AmanCard(
                  onTap: () => context.push('/documents/${d.id}'),
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(14)),
                        child: Icon(docIcon(d), color: d.isPdf ? p.error : p.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleSmall),
                            const SizedBox(height: 3),
                            Text('${d.kind.label(l)} · ${context.fmt.shortDate(d.uploadedAt)} · ${formatSize(d.sizeBytes)}', style: t.bodySmall),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right_rounded, color: p.textSecondary),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Future<void> showUploadSheet(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _UploadSheet(),
    );

class _UploadSheet extends ConsumerStatefulWidget {
  const _UploadSheet();

  @override
  ConsumerState<_UploadSheet> createState() => _UploadSheetState();
}

class _UploadSheetState extends ConsumerState<_UploadSheet> {
  final _title = TextEditingController();
  PickedFile? _file;
  DocumentKind _kind = DocumentKind.other;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final picked = await ref.read(filePickerProvider).pickDocument();
    if (picked == null || !mounted) return;
    String? error;
    try {
      DocumentPolicy.validate(picked.name, picked.bytes.length);
    } on UploadException catch (e) {
      error = errorMessage(context.l10n, e);
    }
    setState(() {
      _file = error == null ? picked : null;
      _error = error;
      if (error == null && _title.text.isEmpty) _title.text = picked.name.replaceAll(RegExp(r'\.[^.]+$'), '');
    });
  }

  Future<void> _upload() async {
    final l = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(documentsProvider.notifier).upload(
            fileName: _file!.name,
            bytes: _file!.bytes,
            title: _title.text,
            kind: _kind,
          );
      if (!mounted) return;
      Navigator.pop(context);
      showSnack(context, l.uploadSuccess);
    } catch (e) {
      if (mounted) setState(() => _error = errorMessage(l, e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.uploadDocument, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 14),
            InkWell(
              onTap: _pick,
              borderRadius: BorderRadius.circular(18),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: p.lightBlue,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(_file == null ? Icons.attach_file_rounded : Icons.check_circle_rounded, color: p.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _file == null ? l.pickFile : '${_file!.name} · ${formatSize(_file!.bytes.length)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(l.uploadHint, style: Theme.of(context).textTheme.bodySmall),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_error!, style: TextStyle(color: p.error, fontWeight: FontWeight.w600)),
              ),
            const SizedBox(height: 16),
            AmanTextField(label: l.docTitleLabel, controller: _title, maxLength: 120),
            const SizedBox(height: 12),
            Text(l.docKindLabel, style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final k in DocumentKind.values)
                  AmanFilterChip(label: k.label(l), selected: _kind == k, onTap: () => setState(() => _kind = k)),
              ],
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: l.uploadDocument, loading: _busy, onPressed: _file == null ? null : _upload),
          ],
        ),
      ),
    );
  }
}
