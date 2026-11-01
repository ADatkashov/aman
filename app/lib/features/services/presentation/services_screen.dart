import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../booking/application/booking_draft.dart';
import '../../catalog/application/catalog_providers.dart';
import 'telemedicine_sheet.dart';

class ServicesScreen extends ConsumerWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;

    final items = <(IconData, String, String, VoidCallback, bool)>[
      (Icons.medical_services_rounded, l.doctorsTitle, l.svcDoctorsDesc, () {
        ref.read(doctorFilterProvider.notifier).reset();
        context.push('/doctors');
      }, false),
      (Icons.event_available_rounded, l.bookDoctor, l.svcBookDesc, () {
        ref.read(bookingDraftProvider.notifier).start();
        context.push('/booking');
      }, false),
      (Icons.science_rounded, l.analysesTitle, l.svcAnalysesDesc, () => context.push('/analyses'), false),
      (Icons.folder_shared_rounded, l.recordTitle, l.svcRecordDesc, () => context.push('/medical-record'), false),
      (Icons.description_rounded, l.documentsTitle, l.svcDocumentsDesc, () => context.push('/documents'), false),
      (Icons.map_rounded, l.clinicsTitle, l.svcClinicsDesc, () => context.push('/clinics'), false),
      (Icons.videocam_rounded, l.qsTelemedicine, l.telemedTitle, () => showTelemedicineSheet(context, ref), true),
    ];

    return Scaffold(
      appBar: CustomAppBar(title: l.servicesTitle, showBack: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        children: [
          Text(l.servicesSubtitle, style: t.bodyMedium?.copyWith(color: p.textSecondary)),
          const SizedBox(height: 16),
          for (final i in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AmanCard(
                onTap: i.$4,
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(color: p.lightBlue, borderRadius: BorderRadius.circular(16)),
                      child: Icon(i.$1, color: p.primary, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(i.$2, style: t.titleSmall), const SizedBox(height: 2), Text(i.$3, style: t.bodySmall)],
                      ),
                    ),
                    if (i.$5) StatusBadge(label: l.comingSoon, tone: BadgeTone.warning) else Icon(Icons.chevron_right_rounded, color: p.textSecondary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
