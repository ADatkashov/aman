import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../application/documents_controller.dart';
import '../domain/medical_document.dart';
import 'documents_screen.dart';

class DocumentDetailScreen extends ConsumerWidget {
  const DocumentDetailScreen({super.key, required this.documentId});
  final String documentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final doc = ref.watch(documentProvider(documentId));
    return Scaffold(
      appBar: CustomAppBar(title: l.documentsTitle),
      body: doc.when(
        loading: () => const LoadingState(itemCount: 2, itemHeight: 160),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(documentProvider(documentId)),
        ),
        data: (d) => _Body(doc: d),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.doc});
  final MedicalDocument doc;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        AmanCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(doc.title, style: t.titleLarge),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  StatusBadge(label: doc.kind.label(l), tone: BadgeTone.info),
                  StatusBadge(
                    label: doc.isPdf
                        ? l.pdfLabel
                        : doc.mimeType.split('/').last.toUpperCase(),
                    tone: BadgeTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              InfoRow(
                icon: Icons.event_rounded,
                label: l.labDate,
                value: fmt.dayMonthYear(doc.uploadedAt),
              ),
              InfoRow(
                icon: Icons.insert_drive_file_rounded,
                label: doc.fileName,
                value: formatSize(doc.sizeBytes),
              ),
              InfoRow(
                icon: Icons.person_rounded,
                label: l.statusLabel,
                value: doc.uploadedByPatient
                    ? l.docUploadedBy
                    : l.docUploadedByClinic,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (doc.isImage && doc.bytes != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.memory(doc.bytes!, fit: BoxFit.contain),
          )
        else if (doc.previewText != null)
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: p.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.previewText!.of(context.langCode),
                  style: t.bodyMedium?.copyWith(
                    color: const Color(0xFF172B4D),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 14),
                Text(l.docDemoNotice, style: t.labelSmall),
              ],
            ),
          )
        else
          AmanCard(
            child: Row(
              children: [
                Icon(Icons.picture_as_pdf_rounded, color: p.error, size: 32),
                const SizedBox(width: 12),
                Expanded(child: Text(l.docPdfNotice, style: t.bodyMedium)),
              ],
            ),
          ),
        if (doc.uploadedByPatient) ...[
          const SizedBox(height: 18),
          SecondaryButton(
            label: l.deleteDocument,
            destructive: true,
            icon: Icons.delete_outline_rounded,
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: l.deleteDocument,
                body: l.deleteDocumentConfirm,
                confirmLabel: l.delete,
                destructive: true,
              );
              if (!ok) return;
              await ref.read(documentsProvider.notifier).delete(doc.id);
              if (context.mounted) {
                showSnack(context, l.documentDeleted);
                context.pop();
              }
            },
          ),
        ],
      ],
    );
  }
}
