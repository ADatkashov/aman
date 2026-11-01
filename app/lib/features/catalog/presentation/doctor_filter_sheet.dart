import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../application/catalog_providers.dart';
import '../domain/doctor_filter.dart';

Future<void> showDoctorFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerStatefulWidget {
  const _FilterSheet();

  @override
  ConsumerState<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<_FilterSheet> {
  late DoctorFilter _draft = ref.read(doctorFilterProvider);

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final clinics = ref.watch(clinicsProvider).value ?? const [];
    final t = Theme.of(context).textTheme;

    Widget group(String title, List<Widget> chips) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleSmall),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: chips),
        ],
      ),
    );

    final sortLabels = {
      DoctorSort.popularity: l.sortPopularity,
      DoctorSort.rating: l.sortRating,
      DoctorSort.priceAsc: l.sortPriceAsc,
      DoctorSort.priceDesc: l.sortPriceDesc,
      DoctorSort.experience: l.sortExperience,
    };

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.86,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
        children: [
          Expanded(
            child: ListView(
              controller: controller,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              children: [
                Text(l.filtersTitle, style: t.titleLarge),
                const SizedBox(height: 16),
                group(l.sortTitle, [
                  for (final e in sortLabels.entries)
                    AmanFilterChip(
                      label: e.value,
                      selected: _draft.sort == e.key,
                      onTap: () =>
                          setState(() => _draft = _draft.copyWith(sort: e.key)),
                    ),
                ]),
                group(l.filterClinic, [
                  AmanFilterChip(
                    label: l.anyOption,
                    selected: _draft.clinicId == null,
                    onTap: () => setState(
                      () => _draft = _draft.copyWith(clinicId: null),
                    ),
                  ),
                  for (final c in clinics)
                    AmanFilterChip(
                      label: c.name.replaceAll(' · DEMO', ''),
                      selected: _draft.clinicId == c.id,
                      onTap: () => setState(
                        () => _draft = _draft.copyWith(clinicId: c.id),
                      ),
                    ),
                ]),
                group(l.filterRating, [
                  AmanFilterChip(
                    label: l.anyOption,
                    selected: _draft.minRating == null,
                    onTap: () => setState(
                      () => _draft = _draft.copyWith(minRating: null),
                    ),
                  ),
                  for (final r in [4.5, 4.7, 4.9])
                    AmanFilterChip(
                      label: '★ ${fmt.decimal(r)}+',
                      selected: _draft.minRating == r,
                      onTap: () => setState(
                        () => _draft = _draft.copyWith(minRating: r),
                      ),
                    ),
                ]),
                group(l.filterPrice, [
                  AmanFilterChip(
                    label: l.anyOption,
                    selected: _draft.maxPriceKzt == null,
                    onTap: () => setState(
                      () => _draft = _draft.copyWith(maxPriceKzt: null),
                    ),
                  ),
                  for (final price in [10000, 15000, 20000])
                    AmanFilterChip(
                      label: '≤ ${fmt.money(price)}',
                      selected: _draft.maxPriceKzt == price,
                      onTap: () => setState(
                        () => _draft = _draft.copyWith(maxPriceKzt: price),
                      ),
                    ),
                ]),
                group(l.filterExperience, [
                  AmanFilterChip(
                    label: l.anyOption,
                    selected: _draft.minExperience == null,
                    onTap: () => setState(
                      () => _draft = _draft.copyWith(minExperience: null),
                    ),
                  ),
                  for (final y in [5, 10, 15])
                    AmanFilterChip(
                      label: '$y+',
                      selected: _draft.minExperience == y,
                      onTap: () => setState(
                        () => _draft = _draft.copyWith(minExperience: y),
                      ),
                    ),
                ]),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: SecondaryButton(
                    label: l.reset,
                    onPressed: () => setState(
                      () => _draft = DoctorFilter.empty.copyWith(
                        query: _draft.query,
                        specialty: _draft.specialty,
                        favoritesOnly: _draft.favoritesOnly,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: l.apply,
                    onPressed: () {
                      ref.read(doctorFilterProvider.notifier).set(_draft);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
