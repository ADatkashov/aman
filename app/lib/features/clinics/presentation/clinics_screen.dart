import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/services/external_links.dart';
import '../../../core/services/url_opener.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/clinic.dart';
import '../../catalog/presentation/widgets/clinic_card.dart';
import 'map_adapter.dart';

Future<void> openRoute(BuildContext context, WidgetRef ref, Clinic clinic) async {
  final ok = await ref.read(urlOpenerProvider).open(ExternalLinks.route(clinic, ref.read(appConfigProvider)));
  if (!ok && context.mounted) showSnack(context, context.l10n.routeOpenFailed, error: true);
}

class ClinicsScreen extends ConsumerStatefulWidget {
  const ClinicsScreen({super.key});

  @override
  ConsumerState<ClinicsScreen> createState() => _ClinicsScreenState();
}

class _ClinicsScreenState extends ConsumerState<ClinicsScreen> {
  String _query = '';
  bool _map = true;
  String? _city;
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final clinics = ref.watch(clinicsProvider);
    final adapter = ref.watch(mapAdapterProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: l.clinicsTitle,
        actions: [
          AmanIconButton(
            icon: _map ? Icons.view_list_rounded : Icons.map_rounded,
            tooltip: _map ? l.listView : l.mapView,
            onPressed: () => setState(() => _map = !_map),
          ),
        ],
      ),
      body: AsyncBody<List<Clinic>>(
        value: clinics,
        onRetry: () => ref.invalidate(clinicsProvider),
        builder: (all) {
          final cities = {for (final c in all) c.city}.toList()..sort();
          final byCity = _city == null ? all : all.where((c) => c.city == _city).toList();
          final list = searchClinics(byCity, _query);
          final selected = list.where((c) => c.id == _selectedId).firstOrNull;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: SearchField(hint: l.searchClinicsHint, onChanged: (v) => setState(() => _query = v)),
              ),
              SizedBox(
                height: 42,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    AmanFilterChip(label: l.all, selected: _city == null, onTap: () => setState(() => _city = null)),
                    for (final city in cities) ...[
                      const SizedBox(width: 8),
                      AmanFilterChip(
                        label: city,
                        selected: _city == city,
                        onTap: () => setState(() {
                          _city = _city == city ? null : city;
                          _selectedId = null;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: list.isEmpty
                    ? EmptyState(icon: Icons.location_off_rounded, title: l.noClinicsTitle)
                    : _map
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                            child: Column(
                              children: [
                                Expanded(
                                  child: adapter.build(
                                    context: context,
                                    clinics: list,
                                    selectedId: _selectedId,
                                    onSelect: (c) => setState(() => _selectedId = c.id),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (!adapter.isLive) Text(l.mapDemoNote, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                                const SizedBox(height: 8),
                                if (selected != null)
                                  _SelectedClinicCard(clinic: selected)
                                else
                                  Text(l.clinicsCount(list.length), style: Theme.of(context).textTheme.titleSmall),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                            itemCount: list.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 14),
                            itemBuilder: (_, i) => ClinicCard(clinic: list[i], onTap: () => context.push('/clinics/${list[i].id}')),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SelectedClinicCard extends ConsumerWidget {
  const _SelectedClinicCard({required this.clinic});
  final Clinic clinic;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return AmanCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(clinic.name.replaceAll(' · DEMO', ''), style: t.titleSmall)),
            RatingBadge(rating: clinic.rating),
          ]),
          const SizedBox(height: 4),
          Text(clinic.fullAddress, style: t.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: SecondaryButton(label: l.details, height: 44, onPressed: () => context.push('/clinics/${clinic.id}'))),
              const SizedBox(width: 10),
              Expanded(child: PrimaryButton(label: l.buildRoute, height: 44, icon: Icons.directions_rounded, onPressed: () => openRoute(context, ref, clinic))),
            ],
          ),
        ],
      ),
    );
  }
}
