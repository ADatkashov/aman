import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/when_label.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../catalog/application/catalog_providers.dart';
import '../domain/appointment.dart';

/// Status shown to the user: a confirmed visit in the past reads as completed.
AppointmentStatus displayStatus(Appointment a, DateTime now) =>
    a.status == AppointmentStatus.confirmed && a.isCompleted(now) ? AppointmentStatus.completed : a.status;

BadgeTone toneFor(AppointmentStatus s) => switch (s) {
      AppointmentStatus.confirmed => BadgeTone.info,
      AppointmentStatus.completed => BadgeTone.success,
      AppointmentStatus.cancelled => BadgeTone.error,
    };

class AppointmentCard extends ConsumerWidget {
  const AppointmentCard({super.key, required this.appointment, required this.onTap, this.trailing});

  final Appointment appointment;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final doctor = ref.watch(doctorLookupProvider)(appointment.doctorId);
    final clinic = ref.watch(clinicLookupProvider)(appointment.clinicId);
    final now = ref.watch(clockProvider)();
    final status = displayStatus(appointment, now);

    return AmanCard(
      onTap: onTap,
      semanticLabel: '${doctor?.fullName ?? ''} ${fmt.dateTime(appointment.start)}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (doctor != null)
                DoctorAvatar(seed: doctor.avatarSeed, size: 52, female: doctor.isFemale, photoUrl: doctor.photoUrl),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doctor?.fullName ?? '—', maxLines: 2, overflow: TextOverflow.ellipsis, style: t.titleSmall),
                    Text(doctor?.specialty.label(l) ?? '',
                        style: t.bodySmall?.copyWith(color: p.primary, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    StatusBadge(label: status.label(l), tone: toneFor(status)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(14)),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.event_rounded, size: 18, color: p.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(whenLabel(l, fmt, appointment.start, now), style: t.titleSmall)),
                    Text('#${appointment.number}', style: t.labelSmall),
                  ],
                ),
                if (clinic != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 18, color: p.textSecondary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(clinic.name.replaceAll(' · DEMO', ''),
                            maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(height: 12), trailing!],
        ],
      ),
    );
  }
}
