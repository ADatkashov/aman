import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/buttons.dart';
import '../../booking/application/booking_draft.dart';

/// Telemedicine is not part of the MVP: the sheet explains this honestly and
/// offers the working alternative (in-clinic booking).
Future<void> showTelemedicineSheet(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      final l = sheetContext.l10n;
      final p = sheetContext.palette;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: p.lightBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.videocam_rounded, size: 34, color: p.primary),
              ),
              const SizedBox(height: 16),
              Text(
                l.telemedTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.telemedBody,
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.bodyMedium
                    ?.copyWith(color: p.textSecondary),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: l.bookDoctor,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  ref.read(bookingDraftProvider.notifier).start();
                  context.push('/booking');
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
