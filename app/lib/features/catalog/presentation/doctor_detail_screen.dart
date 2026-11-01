import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../booking/application/booking_draft.dart';
import '../application/catalog_providers.dart';
import '../domain/doctor.dart';

class DoctorDetailScreen extends ConsumerWidget {
  const DoctorDetailScreen({super.key, required this.doctorId});

  final String doctorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final doctor = ref.watch(doctorProvider(doctorId));
    return doctor.when(
      loading: () => Scaffold(
        appBar: CustomAppBar(title: l.doctorsTitle),
        body: const LoadingState(itemCount: 3, itemHeight: 140),
      ),
      error: (e, _) => Scaffold(
        appBar: CustomAppBar(title: l.doctorsTitle),
        body: ErrorState(
          error: e,
          onRetry: () => ref.invalidate(doctorProvider(doctorId)),
        ),
      ),
      data: (d) => _Body(doctor: d),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.doctor});
  final Doctor doctor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final lang = context.langCode;
    final clinic = ref.watch(clinicLookupProvider)(doctor.clinicId);
    final favorite =
        ref.watch(favoritesProvider).value?.contains(doctor.id) ?? false;
    final reviews = ref.watch(doctorReviewsProvider(doctor.id));

    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: t.titleMedium),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [p.lightBlue, p.background],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                            child: Row(
                              children: [
                                AmanIconButton(
                                  icon: Icons.arrow_back_ios_new_rounded,
                                  tooltip: l.back,
                                  onPressed: () => context.pop(),
                                ),
                                const Spacer(),
                                AmanIconButton(
                                  icon: favorite
                                      ? Icons.favorite_rounded
                                      : Icons.favorite_border_rounded,
                                  tooltip: favorite
                                      ? l.removeFavorite
                                      : l.addFavorite,
                                  color: favorite ? p.error : null,
                                  onPressed: () async {
                                    final added = await ref
                                        .read(favoritesProvider.notifier)
                                        .toggle(doctor.id);
                                    if (context.mounted) {
                                      showSnack(
                                        context,
                                        added
                                            ? l.favoriteAdded
                                            : l.favoriteRemoved,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Hero(
                            tag: 'doctor-avatar-${doctor.id}',
                            child: DoctorAvatar(
                              seed: doctor.avatarSeed,
                              size: 168,
                              radius: 40,
                              female: doctor.isFemale,
                              photoUrl: doctor.photoUrl,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: [
                                Text(
                                  doctor.fullName,
                                  textAlign: TextAlign.center,
                                  style: t.headlineSmall,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  doctor.specialty.label(l),
                                  style: t.titleSmall?.copyWith(
                                    color: p.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                _Stat(
                                  icon: Icons.star_rounded,
                                  color: p.warning,
                                  value: fmt.decimal(doctor.rating),
                                  label: l.reviewsCount(doctor.reviewsCount),
                                ),
                                const SizedBox(width: 10),
                                _Stat(
                                  icon: Icons.work_history_rounded,
                                  color: p.primary,
                                  value: l.yearsShort(doctor.experienceYears),
                                  label: l.statExperience,
                                ),
                                const SizedBox(width: 10),
                                _Stat(
                                  icon: Icons.payments_rounded,
                                  color: p.success,
                                  value: fmt.money(doctor.priceKzt),
                                  label: l.consultationPrice,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  sliver: SliverList.list(
                    children: [
                      section(
                        l.doctorAbout,
                        Text(doctor.about.of(lang), style: t.bodyLarge),
                      ),
                      section(
                        l.doctorEducation,
                        Text(doctor.education.of(lang), style: t.bodyMedium),
                      ),
                      section(
                        l.doctorQualification,
                        Text(
                          doctor.qualification.of(lang),
                          style: t.bodyMedium,
                        ),
                      ),
                      section(
                        l.doctorLanguages,
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final code in doctor.languages)
                              StatusBadge(
                                label: switch (code) {
                                  'kk' => l.langName_kk,
                                  'en' => l.langName_en,
                                  _ => l.langName_ru,
                                },
                                tone: BadgeTone.info,
                                icon: Icons.translate_rounded,
                              ),
                          ],
                        ),
                      ),
                      section(
                        l.doctorServices,
                        AmanCard(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          child: Column(
                            children: [
                              for (
                                var i = 0;
                                i < doctor.services.length;
                                i++
                              ) ...[
                                if (i > 0) const Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          doctor.services[i].name.of(lang),
                                          style: t.bodyMedium,
                                        ),
                                      ),
                                      Text(
                                        fmt.money(doctor.services[i].priceKzt),
                                        style: t.titleSmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      if (clinic != null)
                        section(
                          l.doctorWorkplace,
                          AmanCard(
                            onTap: () => context.push('/clinics/${clinic.id}'),
                            child: Row(
                              children: [
                                Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    color: p.lightBlue,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.local_hospital_rounded,
                                    color: p.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        clinic.name.replaceAll(' · DEMO', ''),
                                        style: t.titleSmall,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        clinic.fullAddress,
                                        style: t.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  color: p.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      section(
                        l.doctorSchedule,
                        _SchedulePreview(doctor: doctor),
                      ),
                      section(
                        l.doctorReviews,
                        reviews.when(
                          loading: () => const Skeleton(height: 90, radius: 18),
                          error: (e, _) => ErrorState(
                            error: e,
                            onRetry: () => ref.invalidate(
                              doctorReviewsProvider(doctor.id),
                            ),
                          ),
                          data: (list) => Column(
                            children: [
                              for (final r in list)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: AmanCard(
                                    padding: const EdgeInsets.all(14),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                r.author,
                                                style: t.titleSmall,
                                              ),
                                            ),
                                            RatingBadge(
                                              rating: r.rating.toDouble(),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(r.text, style: t.bodyMedium),
                                        const SizedBox(height: 6),
                                        Text(
                                          fmt.shortDate(r.date),
                                          style: t.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: l.bookButton,
              onPressed: () {
                ref.read(bookingDraftProvider.notifier).start(doctor: doctor);
                context.push('/booking');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Expanded(
      child: AmanCard(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value, style: t.titleSmall),
            ),
            Text(
              label,
              style: t.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Date strip with the available slots of the chosen day. Tapping a slot
/// starts the booking wizard with that slot pre-selected.
class _SchedulePreview extends ConsumerStatefulWidget {
  const _SchedulePreview({required this.doctor});
  final Doctor doctor;

  @override
  ConsumerState<_SchedulePreview> createState() => _SchedulePreviewState();
}

class _SchedulePreviewState extends ConsumerState<_SchedulePreview> {
  late DateTime _day = Dates.dateOnly(ref.read(clockProvider)());

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final fmt = context.fmt;
    final today = Dates.dateOnly(ref.read(clockProvider)());
    final slots = ref.watch(
      slotsProvider((doctorId: widget.doctor.id, date: _day)),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = today.add(Duration(days: i));
              return DateChip(
                date: d,
                selected: Dates.sameDay(d, _day),
                onTap: () => setState(() => _day = d),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        slots.when(
          loading: () => const Skeleton(height: 48),
          error: (e, _) => ErrorState(
            error: e,
            onRetry: () => ref.invalidate(slotsProvider),
          ),
          data: (list) {
            final free = list.where((s) => s.available).toList();
            if (free.isEmpty) {
              return Text(
                l.noSlotsOnDay,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: p.textSecondary),
              );
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in free)
                  TimeChip(
                    label: fmt.time(s.start),
                    selected: false,
                    onTap: () {
                      ref
                          .read(bookingDraftProvider.notifier)
                          .start(doctor: widget.doctor, slot: s.start);
                      context.push('/booking');
                    },
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class DateChip extends StatelessWidget {
  const DateChip({
    super.key,
    required this.date,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fmt = context.fmt;
    return Semantics(
      button: true,
      selected: selected,
      label: fmt.fullDateLine(date),
      child: Material(
        color: selected ? p.primary : p.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? p.primary : p.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  fmt.weekdayShort(date),
                  style: TextStyle(
                    fontSize: 12,
                    color: selected ? Colors.white70 : p.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${date.day}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : p.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TimeChip extends StatelessWidget {
  const TimeChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      child: Material(
        color: selected ? p.primary : (enabled ? p.surface : p.background),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            width: 78,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: selected ? p.primary : p.border),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.white
                    : (enabled
                          ? p.textPrimary
                          : p.textSecondary.withValues(alpha: 0.5)),
                decoration: enabled ? null : TextDecoration.lineThrough,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
