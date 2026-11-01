import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/services/external_links.dart';
import '../../../core/services/url_opener.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../core/widgets/states.dart';
import '../../appointments/application/appointments_controller.dart';
import '../../catalog/application/catalog_providers.dart';

class BookingSuccessScreen extends ConsumerStatefulWidget {
  const BookingSuccessScreen({super.key, required this.appointmentId});
  final String appointmentId;

  @override
  ConsumerState<BookingSuccessScreen> createState() =>
      _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends ConsumerState<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final appt = ref.watch(appointmentProvider(widget.appointmentId));
    final doctors = ref.watch(doctorLookupProvider);
    final clinics = ref.watch(clinicLookupProvider);

    return Scaffold(
      body: SafeArea(
        child: appt.when(
          loading: () => const LoadingState(itemCount: 2),
          error: (e, _) => ErrorState(error: e),
          data: (a) {
            final doctor = doctors(a.doctorId);
            final clinic = clinics(a.clinicId);
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: ScaleTransition(
                          scale: CurvedAnimation(
                            parent: _c,
                            curve: Curves.elasticOut,
                          ),
                          child: Container(
                            width: 104,
                            height: 104,
                            decoration: BoxDecoration(
                              color: p.success.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 68,
                              color: p.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l.bookingSuccessTitle,
                        textAlign: TextAlign.center,
                        style: t.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        l.bookingSuccessBody,
                        textAlign: TextAlign.center,
                        style: t.bodyMedium?.copyWith(color: p.textSecondary),
                      ),
                      const SizedBox(height: 24),
                      AmanCard(
                        child: Column(
                          children: [
                            InfoRow(
                              icon: Icons.confirmation_number_rounded,
                              label: l.bookingNumber,
                              value: a.number,
                            ),
                            if (doctor != null)
                              InfoRow(
                                icon: Icons.person_rounded,
                                label: l.doctorLabel,
                                value:
                                    '${doctor.fullName}\n${doctor.specialty.label(l)}',
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
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      SecondaryButton(
                        icon: Icons.edit_calendar_rounded,
                        label: l.addToCalendar,
                        onPressed: doctor == null || clinic == null
                            ? null
                            : () async {
                                final uri = ExternalLinks.calendarEvent(
                                  appointment: a,
                                  doctor: doctor,
                                  clinic: clinic,
                                  title:
                                      '${l.appName}: ${doctor.specialty.label(l)}',
                                );
                                final ok = await ref
                                    .read(urlOpenerProvider)
                                    .open(uri);
                                if (!ok && context.mounted) {
                                  showSnack(
                                    context,
                                    l.calendarOpenFailed,
                                    error: true,
                                  );
                                }
                              },
                      ),
                    ],
                  ),
                ),
                BottomActionBar(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PrimaryButton(
                        label: l.goToAppointments,
                        onPressed: () => context.go('/appointments'),
                      ),
                      TextButton(
                        onPressed: () => context.go('/home'),
                        child: Text(l.backHome),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
