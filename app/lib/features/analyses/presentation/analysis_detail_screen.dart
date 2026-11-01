import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../application/lab_providers.dart';
import '../domain/lab_result.dart';
import 'analysis_card.dart';
import 'lab_trend_chart.dart';

class AnalysisDetailScreen extends ConsumerWidget {
  const AnalysisDetailScreen({super.key, required this.resultId});
  final String resultId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final lang = context.langCode;
    final result = ref.watch(labResultProvider(resultId));
    final all = ref.watch(labResultsProvider).value ?? const <LabResult>[];

    return Scaffold(
      appBar: CustomAppBar(title: l.labResultTitle),
      body: result.when(
        loading: () => const LoadingState(itemCount: 3, itemHeight: 130),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(labResultProvider(resultId))),
        data: (r) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
          children: [
            AmanCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(14)),
                        child: Icon(labIcon(r.category), color: p.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(r.name.of(lang), style: t.titleMedium)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  StatusBadge(label: r.status.label(l), tone: labTone(r.status)),
                  const SizedBox(height: 8),
                  InfoRow(icon: Icons.event_rounded, label: l.labDate, value: fmt.dayMonthYear(r.date)),
                  InfoRow(icon: Icons.biotech_rounded, label: l.labLaboratory, value: r.laboratory),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (!r.hasValues)
              AmanCard(
                child: Row(
                  children: [
                    Icon(Icons.hourglass_top_rounded, color: p.warning),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.labResultPending, style: t.bodyMedium)),
                  ],
                ),
              ),
            for (var i = 0; i < r.indicators.length; i++) ...[
              _IndicatorCard(indicator: r.indicators[i], trend: trendFor(all, r, i)),
              const SizedBox(height: 12),
            ],
            if (r.documentId != null) ...[
              AmanCard(
                onTap: () => context.push('/documents/${r.documentId}'),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf_rounded, color: p.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(l.labOpenDocument, style: t.titleSmall)),
                    Icon(Icons.chevron_right_rounded, color: p.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(16)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: p.primary),
                  const SizedBox(width: 10),
                  Expanded(child: Text(l.labDisclaimer, style: t.bodySmall?.copyWith(color: p.textPrimary))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndicatorCard extends StatelessWidget {
  const _IndicatorCard({required this.indicator, required this.trend});
  final LabIndicator indicator;
  final List<LabTrendPoint> trend;

  String _range(BuildContext context) {
    final l = context.l10n;
    final f = context.fmt.compact;
    final i = indicator;
    if (i.refMin != null && i.refMax != null) return l.labRefRange(f(i.refMax!), f(i.refMin!));
    if (i.refMax != null) return l.labRefLess(f(i.refMax!));
    if (i.refMin != null) return l.labRefMore(f(i.refMin!));
    return '—';
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final i = indicator;
    final out = i.isOutOfRange;
    final color = out ? p.error : p.success;
    final name = i.name.of(context.langCode);

    return AmanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: Text(name, style: t.titleSmall)),
              Text(fmt.compact(i.value), style: t.headlineSmall?.copyWith(color: out ? p.error : p.textPrimary)),
              const SizedBox(width: 4),
              Padding(padding: const EdgeInsets.only(bottom: 3), child: Text(i.unit, style: t.bodySmall)),
            ],
          ),
          const SizedBox(height: 10),
          if (i.hasReference) _RangeBar(indicator: i, color: color),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              style: t.bodySmall,
              children: [
                TextSpan(text: '${l.labReference}: '),
                TextSpan(
                  text: '${_range(context)} ${i.unit}'.trim(),
                  style: TextStyle(fontWeight: FontWeight.w700, color: p.textPrimary),
                ),
              ],
            ),
          ),
          if (i.hasReference) ...[
            const SizedBox(height: 8),
            StatusBadge(
              label: out ? l.labOutOfRange : l.labInRange,
              tone: out ? BadgeTone.error : BadgeTone.success,
              icon: out ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            ),
          ],
          if (trend.length >= 2) ...[
            const SizedBox(height: 16),
            Text(l.labDynamicsFor(name), style: t.labelMedium),
            const SizedBox(height: 8),
            LabTrendChart(points: trend, refMin: i.refMin, refMax: i.refMax),
          ],
        ],
      ),
    );
  }
}

/// Horizontal scale showing the value against the laboratory interval.
class _RangeBar extends StatelessWidget {
  const _RangeBar({required this.indicator, required this.color});
  final LabIndicator indicator;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final i = indicator;
    final lo = i.refMin ?? 0;
    final hi = i.refMax ?? (i.value > lo ? i.value * 1.5 : lo * 1.5 + 1);
    final span = (hi - lo).abs() < 1e-9 ? 1.0 : hi - lo;
    // Scale: interval occupies the middle 60%.
    final pos = (0.2 + 0.6 * (i.value - lo) / span).clamp(0.02, 0.98);
    return SizedBox(
      height: 16,
      child: LayoutBuilder(
        builder: (_, c) => Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(height: 8, decoration: BoxDecoration(color: p.border, borderRadius: BorderRadius.circular(6))),
            Positioned(
              left: c.maxWidth * 0.2,
              width: c.maxWidth * 0.6,
              child: Container(height: 8, decoration: BoxDecoration(color: p.success.withValues(alpha: 0.35), borderRadius: BorderRadius.circular(6))),
            ),
            Positioned(
              left: c.maxWidth * pos - 8,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: p.surface, width: 3)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
