import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../auth/application/auth_controller.dart';
import '../application/medical_record_providers.dart';
import '../domain/medical_entry.dart';
import 'medical_record_card.dart';

class MedicalRecordScreen extends ConsumerStatefulWidget {
  const MedicalRecordScreen({super.key});

  @override
  ConsumerState<MedicalRecordScreen> createState() =>
      _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends ConsumerState<MedicalRecordScreen> {
  /// `null` = "General" overview.
  MedicalEntryType? _type;
  bool _general = true;
  DateTimeRange? _range;

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(1990),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
    );
    if (picked != null) setState(() => _range = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final entries = ref.watch(medicalEntriesProvider);
    final profile = ref.watch(authControllerProvider).value;

    return Scaffold(
      appBar: CustomAppBar(
        title: l.recordTitle,
        actions: [
          AmanIconButton(
            icon: _range == null
                ? Icons.date_range_rounded
                : Icons.event_available_rounded,
            tooltip: l.recFilterDates,
            color: _range == null ? null : p.primary,
            onPressed: _pickRange,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                AmanFilterChip(
                  label: l.recGeneral,
                  selected: _general,
                  onTap: () => setState(() {
                    _general = true;
                    _type = null;
                  }),
                ),
                for (final type in MedicalEntryType.values) ...[
                  const SizedBox(width: 8),
                  AmanFilterChip(
                    label: type.label(l),
                    icon: entryIcon(type),
                    selected: !_general && _type == type,
                    onTap: () => setState(() {
                      _general = false;
                      _type = type;
                    }),
                  ),
                ],
              ],
            ),
          ),
          if (_range != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  StatusBadge(
                    label:
                        '${fmt.shortDate(_range!.start)} – ${fmt.shortDate(_range!.end)}',
                    tone: BadgeTone.info,
                    icon: Icons.date_range_rounded,
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () => setState(() => _range = null),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: p.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(medicalEntriesProvider);
                await ref.read(medicalEntriesProvider.future);
              },
              child: AsyncBody<List<MedicalEntry>>(
                value: entries,
                onRetry: () => ref.invalidate(medicalEntriesProvider),
                builder: (all) {
                  final filtered = filterEntries(
                    all,
                    type: _type,
                    from: _range?.start,
                    to: _range?.end,
                  );
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    children: [
                      if (_general && profile != null) ...[
                        AmanCard(
                          child: Column(
                            children: [
                              InfoRow(
                                icon: Icons.person_rounded,
                                label: l.fullNameLabel,
                                value: profile.fullName,
                              ),
                              InfoRow(
                                icon: Icons.cake_rounded,
                                label: l.birthDateLabel,
                                value: profile.birthDate == null
                                    ? '—'
                                    : '${fmt.dayMonthYear(profile.birthDate!)} · ${l.recAgeValue(profile.ageAt(DateTime.now()) ?? 0)}',
                              ),
                              InfoRow(
                                icon: Icons.bloodtype_rounded,
                                label: l.bloodTypeLabel,
                                value: profile.bloodType ?? '—',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(l.recTimeline, style: t.titleMedium),
                        const SizedBox(height: 10),
                      ],
                      if (filtered.isEmpty)
                        EmptyState(
                          icon: Icons.folder_open_rounded,
                          title: l.recEmpty,
                          compact: true,
                        )
                      else
                        for (final e in filtered)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MedicalRecordCard(
                              entry: e,
                              onTap: () => _open(context, e),
                            ),
                          ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: p.lightBlue,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 18,
                              color: p.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                l.recDisclaimer,
                                style: t.bodySmall?.copyWith(
                                  color: p.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Entries link back to the document / lab result / visit that confirms them.
  void _open(BuildContext context, MedicalEntry e) {
    final ref = e.sourceRef;
    if (ref.startsWith('doc')) {
      context.push('/documents/$ref');
    } else if (ref.startsWith('l')) {
      context.push('/analyses/$ref');
    }
  }
}
