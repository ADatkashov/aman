import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/when_label.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../analyses/application/lab_providers.dart';
import '../../analyses/presentation/analysis_card.dart';
import '../../appointments/application/appointments_controller.dart';
import '../../appointments/domain/appointment.dart';
import '../../auth/application/auth_controller.dart';
import '../../booking/application/booking_draft.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/doctor_filter.dart';
import '../../catalog/domain/specialty.dart';
import '../../catalog/presentation/widgets/doctor_card.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../services/presentation/telemedicine_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(doctorsProvider);
    ref.invalidate(clinicsProvider);
    ref.invalidate(labResultsProvider);
    ref.invalidate(nextSlotProvider);
    await Future.wait([
      ref.read(appointmentsProvider.notifier).refresh(),
      ref.read(notificationsProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const _Header(),
              const SizedBox(height: 18),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _NextAppointment(),
              ),
              const SizedBox(height: 26),
              SectionHeader(title: l.quickServices),
              const SizedBox(height: 12),
              const _QuickServices(),
              const SizedBox(height: 26),
              SectionHeader(title: l.popularSpecialties),
              const SizedBox(height: 12),
              const _Specialties(),
              const SizedBox(height: 26),
              SectionHeader(
                title: l.popularDoctors,
                onAction: () {
                  ref.read(doctorFilterProvider.notifier).reset();
                  context.push('/doctors');
                },
              ),
              const SizedBox(height: 12),
              const _PopularDoctors(),
              const SizedBox(height: 26),
              SectionHeader(
                title: l.myResults,
                onAction: () => context.push('/analyses'),
              ),
              const SizedBox(height: 12),
              const _Results(),
              const SizedBox(height: 26),
              SectionHeader(title: l.careTitle),
              const SizedBox(height: 12),
              SizedBox(
                height: 132,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _CareCard(
                      Icons.health_and_safety_rounded,
                      l.careTip1Title,
                      l.careTip1Body,
                      p.primary,
                    ),
                    _CareCard(
                      Icons.water_drop_rounded,
                      l.careTip2Title,
                      l.careTip2Body,
                      const Color(0xFF0B9FB8),
                    ),
                    _CareCard(
                      Icons.vaccines_rounded,
                      l.careTip3Title,
                      l.careTip3Body,
                      p.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final profile = ref.watch(authControllerProvider).value;
    final unread = ref.watch(unreadCountProvider);
    final now = ref.watch(clockProvider)();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: () => context.go('/profile'),
            child: InitialsAvatar(name: profile?.fullName ?? 'A', size: 50),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.greeting(profile?.firstName ?? ''),
                  style: t.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(context.fmt.fullDateLine(now), style: t.bodySmall),
              ],
            ),
          ),
          AmanIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: l.openNotifications,
            badge: unread,
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
    );
  }
}

class _NextAppointment extends ConsumerWidget {
  const _NextAppointment();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final next = ref.watch(nextAppointmentProvider);
    return next.when(
      loading: () => const Skeleton(height: 190, radius: 24),
      error: (e, _) => ErrorState(
        error: e,
        onRetry: () => ref.invalidate(appointmentsProvider),
      ),
      data: (a) {
        if (a == null) {
          return AmanCard(
            child: Column(
              children: [
                EmptyState(
                  compact: true,
                  icon: Icons.event_available_rounded,
                  title: l.noAppointmentsTitle,
                  body: l.noAppointmentsBody,
                  actionLabel: l.bookDoctor,
                  onAction: () => _startBooking(context, ref),
                ),
              ],
            ),
          );
        }
        return _NextCard(appointment: a);
      },
    );
  }
}

void _startBooking(
  BuildContext context,
  WidgetRef ref, {
  Specialty? specialty,
}) {
  ref.read(bookingDraftProvider.notifier).start(specialty: specialty);
  context.push('/booking');
}

class _NextCard extends ConsumerWidget {
  const _NextCard({required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final doctor = ref.watch(doctorLookupProvider)(appointment.doctorId);
    final clinic = ref.watch(clinicLookupProvider)(appointment.clinicId);
    final now = ref.watch(clockProvider)();
    final onBlue = Colors.white.withValues(alpha: 0.85);
    return Semantics(
      container: true,
      label: l.nextAppointment,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [p.secondary, p.primary, p.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: p.primary.withValues(alpha: 0.32),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.nextAppointment,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelMedium?.copyWith(color: onBlue),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    l.statusConfirmed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              whenLabel(l, fmt, appointment.start, now),
              style: t.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (doctor != null)
                  DoctorAvatar(
                    seed: doctor.avatarSeed,
                    size: 46,
                    female: doctor.isFemale,
                    photoUrl: doctor.photoUrl,
                    radius: 23,
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor?.specialty.label(l) ?? '',
                        style: t.bodySmall?.copyWith(color: onBlue),
                      ),
                      Text(
                        doctor?.shortName ?? '',
                        style: t.titleMedium?.copyWith(color: Colors.white),
                      ),
                      if (clinic != null)
                        Text(
                          clinic.name.replaceAll(' · DEMO', ''),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(color: onBlue),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: p.primaryDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () =>
                    context.push('/appointments/${appointment.id}'),
                child: Text(
                  l.details,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickServices extends ConsumerWidget {
  const _QuickServices();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final items = <(IconData, String, VoidCallback)>[
      (
        Icons.event_available_rounded,
        l.qsBook,
        () => _startBooking(context, ref),
      ),
      (Icons.science_rounded, l.qsAnalyses, () => context.push('/analyses')),
      (
        Icons.folder_shared_rounded,
        l.qsRecord,
        () => context.push('/medical-record'),
      ),
      (
        Icons.description_rounded,
        l.qsDocuments,
        () => context.push('/documents'),
      ),
      (Icons.map_rounded, l.qsClinics, () => context.push('/clinics')),
      (
        Icons.videocam_rounded,
        l.qsTelemedicine,
        () => showTelemedicineSheet(context, ref),
      ),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.95,
        children: [
          for (final i in items)
            _QuickTile(icon: i.$1, label: i.$2, onTap: i.$3),
        ],
      ),
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return AmanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(8),
      semanticLabel: label.replaceAll('\n', ' '),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: p.lightBlue,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: p.primary),
          ),
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Specialties extends ConsumerWidget {
  const _Specialties();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: Specialty.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) {
          final s = Specialty.values[i];
          return ActionChip2(
            icon: s.icon,
            label: s.label(l),
            onTap: () {
              ref
                  .read(doctorFilterProvider.notifier)
                  .set(DoctorFilter(specialty: s));
              context.push('/doctors');
            },
          );
        },
      ),
    );
  }
}

class ActionChip2 extends StatelessWidget {
  const ActionChip2({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: p.primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PopularDoctors extends ConsumerWidget {
  const _PopularDoctors();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider);
    // Grow with the user's text scale so cards never clip.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final height = 208 + (scale - 1) * 90;
    return SizedBox(
      height: height,
      child: doctors.when(
        loading: () => ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            for (var i = 0; i < 3; i++)
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Skeleton(width: 210, height: 208, radius: 20),
              ),
          ],
        ),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(doctorsProvider),
        ),
        data: (all) {
          final top =
              ([...all]
                    ..sort((a, b) => b.reviewsCount.compareTo(a.reviewsCount)))
                  .take(6)
                  .toList();
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: top.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (_, i) => DoctorMiniCard(
              doctor: top[i],
              onTap: () => context.push('/doctors/${top[i].id}'),
              onBook: () {
                ref.read(bookingDraftProvider.notifier).start(doctor: top[i]);
                context.push('/booking');
              },
            ),
          );
        },
      ),
    );
  }
}

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final results = ref.watch(labResultsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: results.when(
        loading: () => const Skeleton(height: 76, radius: 20),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(labResultsProvider),
        ),
        data: (list) {
          if (list.isEmpty) {
            return AmanCard(
              child: EmptyState(
                compact: true,
                icon: Icons.science_rounded,
                title: l.labNoAnalyses,
                body: l.labNoAnalysesBody,
              ),
            );
          }
          return Column(
            children: [
              for (final r in list.take(3))
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: AnalysisCard(
                    title: r.name.of(context.langCode),
                    category: r.category,
                    date: r.date,
                    status: r.status,
                    onTap: () => context.push('/analyses/${r.id}'),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CareCard extends StatelessWidget {
  const _CareCard(this.icon, this.title, this.body, this.color);
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withValues(alpha: 0.10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: t.titleSmall)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              body,
              style: t.bodySmall?.copyWith(color: t.bodyMedium?.color),
              overflow: TextOverflow.fade,
            ),
          ),
        ],
      ),
    );
  }
}
