import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/states.dart';
import '../../booking/application/booking_draft.dart';
import '../../catalog/application/catalog_providers.dart';
import '../application/appointments_controller.dart';
import '../domain/appointment.dart';
import 'appointment_actions.dart';
import 'appointment_card.dart';

class AppointmentsScreen extends ConsumerStatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  ConsumerState<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends ConsumerState<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(() => setState(() {}));
  AppointmentPeriod _period = AppointmentPeriod.all;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final appts = ref.watch(appointmentsProvider);
    ref.watch(doctorsProvider);
    ref.watch(clinicsProvider);
    final now = ref.watch(clockProvider)();
    final tab = AppointmentTab.values[_tabs.index];

    final periodLabels = {
      AppointmentPeriod.all: l.periodAll,
      AppointmentPeriod.days30: l.period30,
      AppointmentPeriod.days90: l.period90,
      AppointmentPeriod.days365: l.period365,
    };

    return Scaffold(
      appBar: CustomAppBar(
        title: l.appointmentsTitle,
        showBack: false,
        actions: [
          AmanIconButton(
            icon: Icons.add_rounded,
            tooltip: l.bookDoctor,
            color: p.primary,
            onPressed: () {
              ref.read(bookingDraftProvider.notifier).start();
              context.push('/booking');
            },
          ),
        ],
      ),
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
                for (final t in [l.tabUpcoming, l.tabCompleted, l.tabCancelled])
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
                for (final e in periodLabels.entries) ...[
                  AmanFilterChip(
                    label: e.value,
                    selected: _period == e.key,
                    onTap: () => setState(() => _period = e.key),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () =>
                  ref.read(appointmentsProvider.notifier).refresh(),
              child: AsyncBody<List<Appointment>>(
                value: appts,
                onRetry: () => ref.invalidate(appointmentsProvider),
                builder: (all) {
                  final list = selectAppointments(
                    all,
                    tab: tab,
                    period: _period,
                    now: now,
                  );
                  if (list.isEmpty) {
                    return ListView(
                      children: [
                        const SizedBox(height: 40),
                        EmptyState(
                          icon: switch (tab) {
                            AppointmentTab.upcoming =>
                              Icons.event_available_rounded,
                            AppointmentTab.completed => Icons.task_alt_rounded,
                            AppointmentTab.cancelled =>
                              Icons.event_busy_rounded,
                          },
                          title: switch (tab) {
                            AppointmentTab.upcoming => l.noUpcomingTitle,
                            AppointmentTab.completed => l.noCompletedTitle,
                            AppointmentTab.cancelled => l.noCancelledTitle,
                          },
                          body: _period == AppointmentPeriod.all
                              ? l.noAppointmentsBody
                              : l.noAppointmentsInPeriod,
                          actionLabel: tab == AppointmentTab.upcoming
                              ? l.bookDoctor
                              : null,
                          onAction: tab == AppointmentTab.upcoming
                              ? () {
                                  ref
                                      .read(bookingDraftProvider.notifier)
                                      .start();
                                  context.push('/booking');
                                }
                              : null,
                        ),
                      ],
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
                    itemCount: list.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 14),
                    itemBuilder: (_, i) {
                      final a = list[i];
                      return AppointmentCard(
                        appointment: a,
                        onTap: () => context.push('/appointments/${a.id}'),
                        trailing: AppointmentActions(
                          appointment: a,
                          compact: true,
                        ),
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

/// Action buttons that depend on the appointment's state and clinic policy.
class AppointmentActions extends ConsumerWidget {
  const AppointmentActions({
    super.key,
    required this.appointment,
    this.compact = false,
  });

  final Appointment appointment;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final now = ref.watch(clockProvider)();
    final clinic = ref.watch(clinicLookupProvider)(appointment.clinicId);
    final a = appointment;
    final h = compact ? 44.0 : 52.0;

    if (a.isUpcoming(now)) {
      final canChange = clinic != null && a.canChange(clinic, now);
      final reschedule = SecondaryButton(
        label: compact ? l.actionReschedule : l.rescheduleAppointment,
        height: h,
        onPressed: canChange
            ? () => context.push('/appointments/${a.id}/reschedule')
            : null,
      );
      final cancel = SecondaryButton(
        label: compact ? l.actionCancel : l.cancelAppointment,
        destructive: true,
        height: h,
        onPressed: canChange ? () => cancelFlow(context, ref, a) : null,
      );
      return Column(
        children: [
          if (compact)
            Row(
              children: [
                Expanded(child: reschedule),
                const SizedBox(width: 10),
                Expanded(child: cancel),
              ],
            )
          else ...[
            reschedule,
            const SizedBox(height: 10),
            cancel,
          ],
          if (!canChange && clinic != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                l.errTooLate(clinic.changeDeadlineHours),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      );
    }
    if (a.status == AppointmentStatus.cancelled) {
      return SecondaryButton(
        label: l.repeatAppointment,
        height: h,
        onPressed: () => repeatFlow(context, ref, a),
      );
    }
    return Row(
      children: [
        Expanded(
          child: SecondaryButton(
            label: l.repeatAppointment,
            height: h,
            onPressed: () => repeatFlow(context, ref, a),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: a.reviewRating != null
              ? Container(
                  height: h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.palette.lightBlue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded, color: context.palette.warning),
                      const SizedBox(width: 4),
                      Text(
                        '${a.reviewRating}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                )
              : PrimaryButton(
                  label: l.leaveReview,
                  height: h,
                  onPressed: () => reviewFlow(context, ref, a),
                ),
        ),
      ],
    );
  }
}
