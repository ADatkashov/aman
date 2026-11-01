import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/when_label.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../application/notifications_controller.dart';
import '../domain/app_notification.dart';

/// Localized title/body for a notification, built from its parameters.
({String title, String body, IconData icon}) renderNotification(
  AppL10n l,
  AmanFormat fmt,
  AppNotification n,
  DateTime now,
) {
  final start = DateTime.tryParse(n.params['start'] ?? '')?.toLocal();
  final when = start == null ? '' : whenLabel(l, fmt, start, now);
  final doctor = n.params['doctor'] ?? '';
  return switch (n.type) {
    NotificationType.appointmentCreated =>
      (title: l.ntCreatedTitle, body: l.ntCreatedBody(doctor, when), icon: Icons.event_available_rounded),
    NotificationType.appointmentReminder =>
      (title: l.ntReminderTitle, body: l.ntReminderBody(doctor, when), icon: Icons.alarm_rounded),
    NotificationType.appointmentRescheduled =>
      (title: l.ntRescheduledTitle, body: l.ntRescheduledBody(doctor, when), icon: Icons.update_rounded),
    NotificationType.appointmentCancelled =>
      (title: l.ntCancelledTitle, body: l.ntCancelledBody(doctor, when), icon: Icons.event_busy_rounded),
    NotificationType.labReady => (title: l.ntLabReadyTitle, body: l.ntLabReadyBody, icon: Icons.science_rounded),
    NotificationType.newPrescription =>
      (title: l.ntPrescriptionTitle, body: l.ntPrescriptionBody(doctor), icon: Icons.medication_rounded),
    NotificationType.scheduleChanged =>
      (title: l.ntScheduleTitle, body: l.ntScheduleBody(doctor), icon: Icons.edit_calendar_rounded),
  };
}

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final items = ref.watch(notificationsProvider);
    final now = ref.watch(clockProvider)();
    final controller = ref.read(notificationsProvider.notifier);

    return Scaffold(
      appBar: CustomAppBar(
        title: l.notificationsTitle,
        actions: [
          AmanIconButton(
            icon: Icons.done_all_rounded,
            tooltip: l.markAllRead,
            color: p.primary,
            onPressed: () => controller.markAllRead(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refresh,
        child: AsyncBody<List<AppNotification>>(
          value: items,
          onRetry: () => ref.invalidate(notificationsProvider),
          builder: (list) {
            if (list.isEmpty) {
              return ListView(children: [
                const SizedBox(height: 60),
                EmptyState(icon: Icons.notifications_none_rounded, title: l.noNotificationsTitle, body: l.noNotificationsBody),
              ]);
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
              itemCount: list.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) {
                final n = list[i];
                final r = renderNotification(l, fmt, n, now);
                return Dismissible(
                  key: ValueKey(n.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 24),
                    decoration: BoxDecoration(color: p.error, borderRadius: BorderRadius.circular(20)),
                    child: const Icon(Icons.delete_rounded, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await controller.delete(n.id);
                    if (context.mounted) showSnack(context, l.notificationDeleted);
                  },
                  child: Material(
                    color: n.read ? p.surface : p.lightBlue,
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        await controller.markRead(n.id);
                        if (n.route != null && context.mounted) context.push(n.route!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(color: p.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(13)),
                              child: Icon(r.icon, color: p.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    Expanded(child: Text(r.title, style: t.titleSmall)),
                                    if (!n.read) Container(width: 9, height: 9, decoration: BoxDecoration(color: p.primary, shape: BoxShape.circle)),
                                  ]),
                                  const SizedBox(height: 3),
                                  Text(r.body, style: t.bodyMedium),
                                  const SizedBox(height: 4),
                                  Text(whenLabel(l, fmt, n.createdAt, now), style: t.bodySmall),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: l.deleteNotification,
                              onPressed: () async {
                                await controller.delete(n.id);
                                if (context.mounted) showSnack(context, l.notificationDeleted);
                              },
                              icon: Icon(Icons.close_rounded, size: 18, color: p.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
