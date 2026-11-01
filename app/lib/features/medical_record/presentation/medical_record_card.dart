import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../domain/medical_entry.dart';

IconData entryIcon(MedicalEntryType t) => switch (t) {
      MedicalEntryType.visit => Icons.event_available_rounded,
      MedicalEntryType.diagnosis => Icons.assignment_rounded,
      MedicalEntryType.prescription => Icons.medication_rounded,
      MedicalEntryType.allergy => Icons.warning_amber_rounded,
      MedicalEntryType.chronic => Icons.monitor_heart_rounded,
      MedicalEntryType.pastIllness => Icons.history_rounded,
      MedicalEntryType.procedure => Icons.healing_rounded,
      MedicalEntryType.vaccination => Icons.vaccines_rounded,
      MedicalEntryType.lab => Icons.science_rounded,
      MedicalEntryType.document => Icons.description_rounded,
    };

class MedicalRecordCard extends StatelessWidget {
  const MedicalRecordCard({super.key, required this.entry, this.onTap});

  final MedicalEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final lang = context.langCode;
    return AmanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(13)),
            child: Icon(entryIcon(entry.type), color: p.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.title.of(lang), style: t.titleSmall),
                if (entry.details != null) ...[
                  const SizedBox(height: 3),
                  Text(entry.details!.of(lang), style: t.bodySmall),
                ],
                const SizedBox(height: 6),
                Text(
                  [context.fmt.shortDate(entry.date), if (entry.doctorName != null) entry.doctorName!].join(' · '),
                  style: t.bodySmall,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.verified_rounded, size: 13, color: p.success),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(l.recConfirmedBy(entry.sourceRef), style: t.labelSmall?.copyWith(color: p.success)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
