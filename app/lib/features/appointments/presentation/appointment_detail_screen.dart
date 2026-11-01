import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../catalog/application/catalog_providers.dart';
import '../application/appointments_controller.dart';
import 'appointment_card.dart';
import 'appointments_screen.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final appt = ref.watch(appointmentProvider(appointmentId));
    ref.watch(doctorsProvider);
    ref.watch(clinicsProvider);
    final now = ref.watch(clockProvider)();

    return Scaffold(
      appBar: CustomAppBar(title: l.appointmentDetails),
      body: appt.when(
        loading: () => const LoadingState(itemCount: 3, itemHeight: 140),
        error: (e, _) => ErrorState(
          error: e,
          onRetry: () => ref.invalidate(appointmentsProvider),
        ),
        data: (a) {
          final doctor = ref.watch(doctorLookupProvider)(a.doctorId);
          final clinic = ref.watch(clinicLookupProvider)(a.clinicId);
          final status = displayStatus(a, now);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            children: [
              AmanCard(
                onTap: doctor == null
                    ? null
                    : () => context.push('/doctors/${doctor.id}'),
                child: Row(
                  children: [
                    if (doctor != null)
                      DoctorAvatar(
                        seed: doctor.avatarSeed,
                        size: 64,
                        female: doctor.isFemale,
                        photoUrl: doctor.photoUrl,
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctor?.fullName ?? '—', style: t.titleMedium),
                          Text(
                            doctor?.specialty.label(l) ?? '',
                            style: t.bodyMedium?.copyWith(color: p.primary),
                          ),
                          const SizedBox(height: 6),
                          StatusBadge(
                            label: status.label(l),
                            tone: toneFor(status),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              AmanCard(
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.confirmation_number_rounded,
                      label: l.bookingNumber,
                      value: a.number,
                    ),
                    InfoRow(
                      icon: Icons.event_rounded,
                      label: l.dateTimeLabel,
                      value:
                          '${fmt.fullDateLine(a.start)}, ${fmt.time(a.start)}',
                    ),
                    if (clinic != null)
                      InfoRow(
                        icon: Icons.location_on_rounded,
                        label: l.clinicLabel,
                        value:
                            '${clinic.name.replaceAll(' · DEMO', '')}\n${clinic.fullAddress}',
                        onTap: () => context.push('/clinics/${clinic.id}'),
                      ),
                    InfoRow(
                      icon: Icons.edit_note_rounded,
                      label: l.reasonLabel,
                      value: a.reason.isEmpty ? '—' : a.reason,
                    ),
                    InfoRow(
                      icon: Icons.payments_rounded,
                      label: l.appointmentPrice,
                      value: fmt.money(a.priceKzt),
                    ),
                    if (a.cancelReason != null && a.cancelReason!.isNotEmpty)
                      InfoRow(
                        icon: Icons.cancel_rounded,
                        label: l.cancelledReasonLabel,
                        value: a.cancelReason!,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppointmentActions(appointment: a),
              if (clinic != null && a.isUpcoming(now)) ...[
                const SizedBox(height: 10),
                Text(
                  l.changePolicy(clinic.changeDeadlineHours),
                  style: t.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
