import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/providers.dart';
import '../../../../core/theme/aman_palette.dart';
import '../../../../core/utils/when_label.dart';
import '../../../../core/widgets/aman_card.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/doctor_avatar.dart';
import '../../../../core/widgets/misc_widgets.dart';
import '../../application/catalog_providers.dart';
import '../../domain/doctor.dart';

/// Catalog card: photo, name, specialty, rating, price, nearest slot, CTA.
class DoctorCard extends ConsumerWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    required this.onBook,
    this.showFavorite = true,
  });

  final Doctor doctor;
  final VoidCallback onTap;
  final VoidCallback onBook;
  final bool showFavorite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final clinic = ref.watch(clinicLookupProvider)(doctor.clinicId);
    final favorite = ref.watch(favoritesProvider).value?.contains(doctor.id) ?? false;
    final next = ref.watch(nextSlotProvider(doctor.id));
    final now = ref.watch(clockProvider)();

    return AmanCard(
      onTap: onTap,
      semanticLabel: '${doctor.fullName}, ${doctor.specialty.label(l)}',
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'doctor-avatar-${doctor.id}',
                child: DoctorAvatar(
                    seed: doctor.avatarSeed, size: 76, female: doctor.isFemale, photoUrl: doctor.photoUrl),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(doctor.fullName,
                              maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleSmall?.copyWith(fontSize: 15)),
                        ),
                        if (showFavorite)
                          InkResponse(
                            radius: 22,
                            onTap: () async {
                              final added = await ref.read(favoritesProvider.notifier).toggle(doctor.id);
                              if (context.mounted) {
                                showSnack(context, added ? l.favoriteAdded : l.favoriteRemoved);
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                size: 22,
                                color: favorite ? p.error : p.textSecondary,
                                semanticLabel: favorite ? l.removeFavorite : l.addFavorite,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(doctor.specialty.label(l), style: t.bodyMedium?.copyWith(color: p.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        RatingBadge(rating: doctor.rating, reviews: doctor.reviewsCount),
                        Text(l.experienceYears(doctor.experienceYears), style: t.bodySmall),
                      ],
                    ),
                    if (clinic != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 14, color: p.textSecondary),
                          const SizedBox(width: 3),
                          Expanded(
                              child: Text(clinic.name.replaceAll(' · DEMO', ''),
                                  maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall)),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.consultationPrice, style: t.bodySmall),
                    Text(fmt.money(doctor.priceKzt), style: t.titleMedium),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: next.when(
                    data: (d) => Text(
                      d == null ? l.noSlotsSoon : l.nearestSlot(whenLabel(l, fmt, d, now)),
                      style: t.bodySmall?.copyWith(color: d == null ? p.textSecondary : p.success, fontWeight: FontWeight.w600),
                      textAlign: TextAlign.end,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, _) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(label: l.bookButton, onPressed: onBook, height: 48),
        ],
      ),
    );
  }
}

/// Compact horizontal card for the home carousel.
class DoctorMiniCard extends ConsumerWidget {
  const DoctorMiniCard({super.key, required this.doctor, required this.onTap, required this.onBook});

  final Doctor doctor;
  final VoidCallback onTap;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return SizedBox(
      width: 210,
      child: AmanCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DoctorAvatar(seed: doctor.avatarSeed, size: 52, female: doctor.isFemale, photoUrl: doctor.photoUrl),
                const SizedBox(width: 10),
                Expanded(child: RatingBadge(rating: doctor.rating)),
              ],
            ),
            const SizedBox(height: 10),
            Text(doctor.shortName, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleSmall),
            Text(doctor.specialty.label(l), style: t.bodySmall?.copyWith(color: p.primary)),
            const SizedBox(height: 4),
            Text(l.experienceYears(doctor.experienceYears), style: t.bodySmall),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(context.fmt.money(doctor.priceKzt), style: t.titleSmall),
                  ),
                ),
                const SizedBox(width: 8),
                Tooltip(
                  message: l.bookButton,
                  child: Material(
                    color: p.primary,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: onBook,
                      child: const SizedBox(
                        width: 38,
                        height: 34,
                        child: Icon(Icons.event_available_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
