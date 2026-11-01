import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../domain/lab_result.dart';

BadgeTone labTone(LabStatus s) => switch (s) {
  LabStatus.pending => BadgeTone.neutral,
  LabStatus.processing => BadgeTone.warning,
  LabStatus.ready => BadgeTone.success,
  LabStatus.attention => BadgeTone.error,
};

IconData labIcon(LabCategory c) => switch (c) {
  LabCategory.cbc => Icons.bloodtype_rounded,
  LabCategory.biochemistry => Icons.science_rounded,
  LabCategory.urine => Icons.water_drop_rounded,
  LabCategory.hormones => Icons.hub_rounded,
  LabCategory.vitamins => Icons.wb_sunny_rounded,
  LabCategory.immunology => Icons.shield_rounded,
  LabCategory.pcr => Icons.biotech_rounded,
  LabCategory.other => Icons.description_rounded,
};

class AnalysisCard extends StatelessWidget {
  const AnalysisCard({
    super.key,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    this.subtitle,
    this.onTap,
  });

  final String title;
  final LabCategory category;
  final DateTime date;
  final LabStatus status;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return AmanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      semanticLabel: title,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: p.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(labIcon(category), color: p.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall,
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle ?? context.fmt.shortDate(date),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall,
                ),
                const SizedBox(height: 6),
                StatusBadge(label: status.label(l), tone: labTone(status)),
              ],
            ),
          ),
          if (onTap != null)
            Icon(Icons.chevron_right_rounded, color: p.textSecondary),
        ],
      ),
    );
  }
}
