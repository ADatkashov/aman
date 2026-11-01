import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/external_links.dart';
import '../../../core/services/url_opener.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/widgets/clinic_card.dart';
import 'clinics_screen.dart';

class ClinicDetailScreen extends ConsumerWidget {
  const ClinicDetailScreen({super.key, required this.clinicId});
  final String clinicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final lang = context.langCode;
    final clinic = ref.watch(clinicProvider(clinicId));
    final doctors = ref.watch(doctorsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: l.clinicsTitle),
      body: clinic.when(
        loading: () => const LoadingState(itemCount: 3, itemHeight: 120),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(clinicProvider(clinicId)),
        ),
        data: (c) {
          final clinicDoctors = (doctors.value ?? const [])
              .where((d) => d.clinicId == c.id)
              .toList();
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                  children: [
                    ClinicCover(clinic: c, height: 150, radius: 24),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name.replaceAll(' · DEMO', ''),
                            style: t.headlineSmall,
                          ),
                        ),
                        if (c.isDemo) const DemoTag(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        RatingBadge(rating: c.rating, reviews: c.reviewsCount),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AmanCard(
                      child: Column(
                        children: [
                          InfoRow(
                            icon: Icons.location_on_rounded,
                            label: c.city,
                            value: c.address,
                          ),
                          InfoRow(
                            icon: Icons.schedule_rounded,
                            label: l.clinicHours,
                            value: c.workingHours.of(lang),
                          ),
                          InfoRow(
                            icon: Icons.call_rounded,
                            label: l.clinicContacts,
                            value: c.phone,
                            onTap: () async {
                              final ok = await ref
                                  .read(urlOpenerProvider)
                                  .open(ExternalLinks.phone(c));
                              if (!ok && context.mounted) {
                                showSnack(context, l.callFailed, error: true);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(l.clinicServices, style: t.titleMedium),
                    const SizedBox(height: 10),
                    AmanCard(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Column(
                        children: [
                          for (var i = 0; i < c.services.length; i++) ...[
                            if (i > 0) const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(c.services[i].name.of(lang)),
                                  ),
                                  Text(
                                    fmt.money(c.services[i].priceKzt),
                                    style: t.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(l.clinicDoctors, style: t.titleMedium),
                    const SizedBox(height: 10),
                    for (final d in clinicDoctors)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: AmanCard(
                          onTap: () => context.push('/doctors/${d.id}'),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              DoctorAvatar(
                                seed: d.avatarSeed,
                                size: 52,
                                female: d.isFemale,
                                photoUrl: d.photoUrl,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(d.fullName, style: t.titleSmall),
                                    Text(
                                      d.specialty.label(l),
                                      style: t.bodySmall?.copyWith(
                                        color: p.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              RatingBadge(rating: d.rating),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              BottomActionBar(
                child: PrimaryButton(
                  label: l.buildRoute,
                  icon: Icons.directions_rounded,
                  onPressed: () => openRoute(context, ref, c),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
