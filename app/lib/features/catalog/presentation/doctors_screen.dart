import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../../booking/application/booking_draft.dart';
import '../application/catalog_providers.dart';
import '../domain/doctor.dart';
import '../domain/doctor_filter.dart';
import '../domain/specialty.dart';
import 'doctor_filter_sheet.dart';
import 'widgets/doctor_card.dart';

class DoctorsScreen extends ConsumerStatefulWidget {
  const DoctorsScreen({super.key, this.favoritesOnly = false});

  /// Opens the screen in "Favorite doctors" mode.
  final bool favoritesOnly;

  @override
  ConsumerState<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends ConsumerState<DoctorsScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: ref.read(doctorFilterProvider).query);
    if (widget.favoritesOnly) {
      // Deferred: providers must not be modified while the tree is building.
      Future.microtask(
        () => ref
            .read(doctorFilterProvider.notifier)
            .set(DoctorFilter.empty.copyWith(favoritesOnly: true)),
      );
    }
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _update(DoctorFilter Function(DoctorFilter) fn) => ref
      .read(doctorFilterProvider.notifier)
      .set(fn(ref.read(doctorFilterProvider)));

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final filter = ref.watch(doctorFilterProvider);
    final doctors = ref.watch(filteredDoctorsProvider);
    // Make sure catalog lookups used by cards are loaded.
    ref.watch(clinicsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.favoritesOnly ? l.favoritesTitle : l.doctorsTitle,
        actions: [
          if (!widget.favoritesOnly)
            AmanIconButton(
              icon: filter.favoritesOnly
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              tooltip: l.favoritesOnly,
              color: filter.favoritesOnly ? context.palette.error : null,
              onPressed: () =>
                  _update((f) => f.copyWith(favoritesOnly: !f.favoritesOnly)),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: SearchField(
              controller: _search,
              hint: l.searchDoctorsHint,
              onChanged: (v) => _update((f) => f.copyWith(query: v)),
              filterBadge:
                  filter.activeAdvancedCount +
                  (filter.sort != DoctorSort.popularity ? 1 : 0),
              onFilterTap: () => showDoctorFilterSheet(context),
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                AmanFilterChip(
                  label: l.all,
                  selected: filter.specialty == null,
                  onTap: () => _update((f) => f.copyWith(specialty: null)),
                ),
                for (final s in Specialty.values) ...[
                  const SizedBox(width: 8),
                  AmanFilterChip(
                    label: s.label(l),
                    selected: filter.specialty == s,
                    onTap: () => _update(
                      (f) => f.copyWith(
                        specialty: filter.specialty == s ? null : s,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(doctorsProvider);
                ref.invalidate(nextSlotProvider);
                await ref.read(doctorsProvider.future);
              },
              child: AsyncBody<List<Doctor>>(
                value: doctors,
                loading: const LoadingState(itemHeight: 210),
                onRetry: () => ref.invalidate(doctorsProvider),
                builder: (list) {
                  if (list.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 60),
                        EmptyState(
                          icon: widget.favoritesOnly || filter.favoritesOnly
                              ? Icons.favorite_border_rounded
                              : Icons.search_off_rounded,
                          title: widget.favoritesOnly
                              ? l.noFavoritesTitle
                              : l.noDoctorsTitle,
                          body: widget.favoritesOnly
                              ? l.noFavoritesBody
                              : l.noDoctorsBody,
                          actionLabel: widget.favoritesOnly
                              ? null
                              : l.resetFilters,
                          onAction: widget.favoritesOnly
                              ? null
                              : () {
                                  _search.clear();
                                  ref
                                      .read(doctorFilterProvider.notifier)
                                      .reset();
                                },
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final d = list[i];
                      return DoctorCard(
                        doctor: d,
                        onTap: () => context.push('/doctors/${d.id}'),
                        onBook: () {
                          ref
                              .read(bookingDraftProvider.notifier)
                              .start(doctor: d);
                          context.push('/booking');
                        },
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
