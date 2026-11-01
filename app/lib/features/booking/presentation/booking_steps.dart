import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/services/external_links.dart';
import '../../../core/services/url_opener.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../appointments/application/appointments_controller.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/doctor.dart';
import '../../catalog/domain/specialty.dart';
import '../../catalog/presentation/doctor_detail_screen.dart' show TimeChip;
import '../../catalog/presentation/widgets/clinic_card.dart';
import '../application/booking_draft.dart';
import '../domain/schedule_service.dart';

/// Step 1 — specialty.
class SpecialtyStep extends ConsumerWidget {
  const SpecialtyStep({super.key, required this.onPicked});
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final draft = ref.watch(bookingDraftProvider);
    return GridView.count(
      padding: const EdgeInsets.all(20),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        for (final s in Specialty.values)
          AmanCard(
            onTap: () {
              ref.read(bookingDraftProvider.notifier).pickSpecialty(s);
              onPicked();
            },
            color: draft.specialty == s ? p.lightBlue : null,
            border: draft.specialty == s,
            padding: const EdgeInsets.all(14),
            semanticLabel: s.label(l),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: draft.specialty == s ? p.primary : p.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    s.icon,
                    color: draft.specialty == s ? Colors.white : p.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.label(l),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Step 2 — doctor of the chosen specialty.
class DoctorStep extends ConsumerWidget {
  const DoctorStep({super.key, required this.onPicked});
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final draft = ref.watch(bookingDraftProvider);
    final doctors = ref.watch(doctorsProvider);
    return AsyncBody<List<Doctor>>(
      value: doctors,
      onRetry: () => ref.invalidate(doctorsProvider),
      builder: (all) {
        final list = all.where((d) => d.specialty == draft.specialty).toList()
          ..sort((a, b) => b.rating.compareTo(a.rating));
        if (list.isEmpty) {
          return EmptyState(
            icon: Icons.person_search_rounded,
            title: l.noDoctorsForSpecialty,
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: list.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, i) {
            final d = list[i];
            final selected = draft.doctor?.id == d.id;
            return AmanCard(
              color: selected ? p.lightBlue : null,
              border: selected,
              onTap: () {
                ref.read(bookingDraftProvider.notifier).pickDoctor(d);
                onPicked();
              },
              child: Row(
                children: [
                  DoctorAvatar(
                    seed: d.avatarSeed,
                    size: 64,
                    female: d.isFemale,
                    photoUrl: d.photoUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.fullName, style: t.titleSmall),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 10,
                          children: [
                            RatingBadge(
                              rating: d.rating,
                              reviews: d.reviewsCount,
                            ),
                            Text(
                              l.experienceYears(d.experienceYears),
                              style: t.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.fmt.money(d.priceKzt),
                          style: t.titleSmall?.copyWith(color: p.primary),
                        ),
                      ],
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, color: p.primary),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// Step 3 — clinic of the visit (the doctor's workplace).
class ClinicStep extends ConsumerWidget {
  const ClinicStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final draft = ref.watch(bookingDraftProvider);
    final clinic = draft.doctor == null
        ? null
        : ref.watch(clinicLookupProvider)(draft.doctor!.clinicId);
    if (clinic == null) {
      return const LoadingState(itemCount: 1, itemHeight: 220);
    }
    final config = ref.watch(appConfigProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ClinicCard(clinic: clinic, onTap: () {}),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () async {
                  final ok = await ref
                      .read(urlOpenerProvider)
                      .open(ExternalLinks.route(clinic, config));
                  if (!ok && context.mounted) {
                    showSnack(context, l.routeOpenFailed, error: true);
                  }
                },
                icon: const Icon(Icons.directions_rounded),
                label: Text(l.buildRoute),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Step 4 — date (four weeks, Monday-first grid).
class DateStep extends ConsumerWidget {
  const DateStep({super.key, required this.onPicked});
  final VoidCallback onPicked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = context.palette;
    final fmt = context.fmt;
    final draft = ref.watch(bookingDraftProvider);
    final now = ref.watch(clockProvider)();
    final today = Dates.dateOnly(now);
    final gridStart = today.subtract(Duration(days: today.weekday - 1));
    final lastBookable = today.add(
      const Duration(days: ScheduleService.bookingHorizonDays),
    );
    final weekdays = [
      for (var i = 0; i < 7; i++)
        fmt.weekdayShort(gridStart.add(Duration(days: i))),
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        AmanCard(
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_month_rounded, color: p.primary),
                  const SizedBox(width: 8),
                  Text(
                    fmt.monthYear(draft.date ?? today),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final w in weekdays)
                    Expanded(
                      child: Center(
                        child: Text(
                          w,
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 7,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                children: [
                  for (var i = 0; i < 35; i++)
                    Builder(
                      builder: (_) {
                        final d = gridStart.add(Duration(days: i));
                        final enabled =
                            !d.isBefore(today) && !d.isAfter(lastBookable);
                        final selected =
                            draft.date != null && Dates.sameDay(d, draft.date!);
                        return Semantics(
                          button: true,
                          enabled: enabled,
                          selected: selected,
                          label: fmt.fullDateLine(d),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: enabled
                                ? () {
                                    ref
                                        .read(bookingDraftProvider.notifier)
                                        .pickDate(d);
                                    onPicked();
                                  }
                                : null,
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: selected
                                    ? p.primary
                                    : (Dates.sameDay(d, today)
                                          ? p.lightBlue
                                          : null),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${d.day}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: selected
                                      ? Colors.white
                                      : (enabled
                                            ? p.textPrimary
                                            : p.textSecondary.withValues(
                                                alpha: 0.4,
                                              )),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Step 5 — free slots of the chosen day (only real availability).
class TimeStep extends ConsumerWidget {
  const TimeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = context.fmt;
    final draft = ref.watch(bookingDraftProvider);
    if (draft.doctor == null || draft.date == null) {
      return const SizedBox.shrink();
    }
    final slots = ref.watch(
      slotsProvider((doctorId: draft.doctor!.id, date: draft.date!)),
    );
    return AsyncBody(
      value: slots,
      onRetry: () => ref.invalidate(slotsProvider),
      loading: const LoadingState(itemCount: 2, itemHeight: 80),
      builder: (list) {
        final anyFree = list.any((s) => s.available);
        if (list.isEmpty || !anyFree) {
          return EmptyState(
            icon: Icons.event_busy_rounded,
            title: l.noSlotsOnDay,
            body: fmt.fullDateLine(draft.date!),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              fmt.fullDateLine(draft.date!),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final s in list)
                  TimeChip(
                    label: fmt.time(s.start),
                    enabled: s.available,
                    selected: draft.slot == s.start,
                    onTap: () => ref
                        .read(bookingDraftProvider.notifier)
                        .pickSlot(s.start),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Step 6 — reason for the visit.
class ReasonStep extends ConsumerStatefulWidget {
  const ReasonStep({super.key, required this.formKey});
  final GlobalKey<FormState> formKey;

  @override
  ConsumerState<ReasonStep> createState() => _ReasonStepState();
}

class _ReasonStepState extends ConsumerState<ReasonStep> {
  late final TextEditingController _c = TextEditingController(
    text: ref.read(bookingDraftProvider).reason,
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final chips = [
      l.reasonChipCheckup,
      l.reasonChipConsult,
      l.reasonChipFollowUp,
      l.reasonChipResults,
    ];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Form(
          key: widget.formKey,
          child: AmanTextField(
            label: l.reasonLabel,
            hint: l.reasonHint,
            controller: _c,
            maxLines: 4,
            maxLength: 300,
            validator: Validators.reason,
            onChanged: (v) =>
                ref.read(bookingDraftProvider.notifier).setReason(v),
          ),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final c in chips)
              AmanFilterChip(
                label: c,
                selected: _c.text == c,
                onTap: () {
                  setState(() => _c.text = c);
                  ref.read(bookingDraftProvider.notifier).setReason(c);
                },
              ),
          ],
        ),
      ],
    );
  }
}

/// Step 7 — summary before confirming.
class ConfirmStep extends ConsumerWidget {
  const ConfirmStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final draft = ref.watch(bookingDraftProvider);
    final doctor = draft.doctor;
    final slot = draft.slot;
    if (doctor == null || slot == null) return const SizedBox.shrink();
    final clinic = ref.watch(clinicLookupProvider)(doctor.clinicId);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(l.bookingSummary, style: t.titleLarge),
        const SizedBox(height: 14),
        AmanCard(
          child: Column(
            children: [
              Row(
                children: [
                  DoctorAvatar(
                    seed: doctor.avatarSeed,
                    size: 60,
                    female: doctor.isFemale,
                    photoUrl: doctor.photoUrl,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(doctor.fullName, style: t.titleSmall),
                        Text(
                          doctor.specialty.label(l),
                          style: t.bodySmall?.copyWith(color: p.primary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),
              InfoRow(
                icon: Icons.event_rounded,
                label: l.dateTimeLabel,
                value: '${fmt.fullDateLine(slot)}, ${fmt.time(slot)}',
              ),
              if (clinic != null)
                InfoRow(
                  icon: Icons.location_on_rounded,
                  label: l.clinicLabel,
                  value:
                      '${clinic.name.replaceAll(' · DEMO', '')}\n${clinic.fullAddress}',
                ),
              InfoRow(
                icon: Icons.edit_note_rounded,
                label: l.reasonLabel,
                value: draft.reason.trim(),
              ),
              InfoRow(
                icon: Icons.payments_rounded,
                label: l.priceLabel,
                value: fmt.money(doctor.priceKzt),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.info_outline_rounded, size: 16, color: p.textSecondary),
            const SizedBox(width: 6),
            Expanded(child: Text(l.payAtClinicNote, style: t.bodySmall)),
          ],
        ),
      ],
    );
  }
}

/// Convenience wrapper so the wizard can create the appointment.
Future<String> confirmBooking(WidgetRef ref) async {
  final draft = ref.read(bookingDraftProvider);
  final created = await ref
      .read(appointmentsProvider.notifier)
      .create(
        doctorId: draft.doctor!.id,
        start: draft.slot!,
        reason: draft.reason,
      );
  return created.id;
}
