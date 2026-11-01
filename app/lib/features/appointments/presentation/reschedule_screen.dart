import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/presentation/doctor_detail_screen.dart' show DateChip, TimeChip;
import '../application/appointments_controller.dart';

class RescheduleScreen extends ConsumerStatefulWidget {
  const RescheduleScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  ConsumerState<RescheduleScreen> createState() => _RescheduleScreenState();
}

class _RescheduleScreenState extends ConsumerState<RescheduleScreen> {
  DateTime? _day;
  DateTime? _slot;
  bool _saving = false;

  Future<void> _save(String doctorId, DateTime slot) async {
    final l = context.l10n;
    setState(() => _saving = true);
    try {
      await ref.read(appointmentsProvider.notifier).reschedule(widget.appointmentId, slot);
      if (!mounted) return;
      showSnack(context, l.appointmentRescheduledSnack);
      context.pop();
    } catch (e) {
      if (!mounted) return;
      showSnack(context, errorMessage(l, e), error: true);
      ref.invalidate(slotsProvider);
      setState(() => _slot = null);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = context.fmt;
    final appt = ref.watch(appointmentProvider(widget.appointmentId));
    final today = Dates.dateOnly(ref.watch(clockProvider)());

    return Scaffold(
      appBar: CustomAppBar(title: l.rescheduleTitle),
      body: appt.when(
        loading: () => const LoadingState(itemCount: 2),
        error: (e, _) => ErrorState(error: e),
        data: (a) {
          final day = _day ?? Dates.dateOnly(a.start);
          final slots = ref.watch(slotsProvider((doctorId: a.doctorId, date: day)));
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    SizedBox(
                      height: 74,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 28,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (_, i) {
                          final d = today.add(Duration(days: i));
                          return DateChip(
                            date: d,
                            selected: Dates.sameDay(d, day),
                            onTap: () => setState(() {
                              _day = d;
                              _slot = null;
                            }),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(fmt.fullDateLine(day), style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    AsyncBody(
                      value: slots,
                      loading: const Skeleton(height: 90),
                      onRetry: () => ref.invalidate(slotsProvider),
                      builder: (list) {
                        if (!list.any((s) => s.available)) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: EmptyState(compact: true, icon: Icons.event_busy_rounded, title: l.noSlotsOnDay),
                          );
                        }
                        return Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            for (final s in list)
                              TimeChip(
                                label: fmt.time(s.start),
                                enabled: s.available && s.start != a.start,
                                selected: _slot == s.start,
                                onTap: () => setState(() => _slot = s.start),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
              BottomActionBar(
                child: PrimaryButton(
                  label: l.rescheduleConfirm,
                  loading: _saving,
                  onPressed: _slot == null ? null : () => _save(a.doctorId, _slot!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
