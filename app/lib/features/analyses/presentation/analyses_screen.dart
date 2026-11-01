import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../application/lab_providers.dart';
import '../domain/lab_result.dart';
import 'analysis_card.dart';

class AnalysesScreen extends ConsumerStatefulWidget {
  const AnalysesScreen({super.key});

  @override
  ConsumerState<AnalysesScreen> createState() => _AnalysesScreenState();
}

class _AnalysesScreenState extends ConsumerState<AnalysesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this)
    ..addListener(() => setState(() {}));
  LabCategory? _category;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final lang = context.langCode;
    final results = ref.watch(labResultsProvider);
    final orders = ref.watch(labOrdersProvider);

    return Scaffold(
      appBar: CustomAppBar(title: l.analysesTitle),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: p.lightBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: TabBar(
              controller: _tabs,
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: p.primary,
              unselectedLabelColor: p.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: [
                for (final t in [l.tabMyAnalyses, l.tabOrders])
                  Tab(
                    child: FittedBox(fit: BoxFit.scaleDown, child: Text(t)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                AmanFilterChip(
                  label: l.catAll,
                  selected: _category == null,
                  onTap: () => setState(() => _category = null),
                ),
                for (final c in LabCategory.values) ...[
                  const SizedBox(width: 8),
                  AmanFilterChip(
                    label: c.label(l),
                    selected: _category == c,
                    onTap: () =>
                        setState(() => _category = _category == c ? null : c),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(labResultsProvider);
                ref.invalidate(labOrdersProvider);
                await ref.read(labResultsProvider.future);
              },
              child: _tabs.index == 0
                  ? AsyncBody<List<LabResult>>(
                      value: results,
                      onRetry: () => ref.invalidate(labResultsProvider),
                      builder: (all) {
                        final list = all
                            .where(
                              (r) =>
                                  _category == null || r.category == _category,
                            )
                            .toList();
                        if (list.isEmpty) {
                          return ListView(
                            children: [
                              const SizedBox(height: 40),
                              EmptyState(
                                icon: Icons.science_rounded,
                                title: l.labNoAnalyses,
                                body: l.labNoAnalysesBody,
                              ),
                            ],
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final r = list[i];
                            return AnalysisCard(
                              title: r.name.of(lang),
                              category: r.category,
                              date: r.date,
                              status: r.status,
                              subtitle:
                                  '${context.fmt.shortDate(r.date)} · ${r.laboratory.replaceAll(' · DEMO', '')}',
                              onTap: () => context.push('/analyses/${r.id}'),
                            );
                          },
                        );
                      },
                    )
                  : AsyncBody<List<LabOrder>>(
                      value: orders,
                      onRetry: () => ref.invalidate(labOrdersProvider),
                      builder: (all) {
                        final list = all
                            .where(
                              (o) =>
                                  _category == null || o.category == _category,
                            )
                            .toList();
                        if (list.isEmpty) {
                          return ListView(
                            children: [
                              const SizedBox(height: 40),
                              EmptyState(
                                icon: Icons.assignment_rounded,
                                title: l.labNoOrders,
                              ),
                            ],
                          );
                        }
                        return ListView.separated(
                          padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                          itemCount: list.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final o = list[i];
                            return AnalysisCard(
                              title: o.name.of(lang),
                              category: o.category,
                              date: o.date,
                              status: o.status,
                              subtitle:
                                  '${l.labPrescribedBy(o.doctorName)} · ${context.fmt.shortDate(o.date)}',
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
