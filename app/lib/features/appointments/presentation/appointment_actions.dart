import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../booking/application/booking_draft.dart';
import '../../catalog/application/catalog_providers.dart';
import '../application/appointments_controller.dart';
import '../domain/appointment.dart';

/// Cancel flow: confirmation dialog with optional reason, then the use case.
Future<void> cancelFlow(
  BuildContext context,
  WidgetRef ref,
  Appointment a,
) async {
  final l = context.l10n;
  final reason = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.cancelConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.cancelConfirmBody),
          const SizedBox(height: 14),
          TextField(
            controller: reason,
            decoration: InputDecoration(hintText: l.cancelReasonHint),
            maxLength: 200,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l.keepAppointment),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: ctx.palette.error),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l.cancelAppointment),
        ),
      ],
    ),
  );
  final text = reason.text.trim();
  reason.dispose();
  if (confirmed != true || !context.mounted) return;
  try {
    await ref
        .read(appointmentsProvider.notifier)
        .cancel(a.id, reason: text.isEmpty ? null : text);
    if (context.mounted) showSnack(context, l.appointmentCancelledSnack);
  } catch (e) {
    if (context.mounted) {
      final clinic = ref.read(clinicLookupProvider)(a.clinicId);
      showSnack(
        context,
        errorMessage(l, e, changeHours: clinic?.changeDeadlineHours ?? 2),
        error: true,
      );
    }
  }
}

/// Review bottom sheet with a 5-star rating and optional comment.
Future<void> reviewFlow(
  BuildContext context,
  WidgetRef ref,
  Appointment a,
) async {
  final l = context.l10n;
  final result = await showModalBottomSheet<(int, String)>(
    context: context,
    isScrollControlled: true,
    builder: (_) => const _ReviewSheet(),
  );
  if (result == null || !context.mounted) return;
  try {
    await ref
        .read(appointmentsProvider.notifier)
        .review(a.id, rating: result.$1, text: result.$2);
    if (context.mounted) showSnack(context, l.reviewThanks);
  } catch (e) {
    if (context.mounted) showSnack(context, errorMessage(l, e), error: true);
  }
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet();

  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  int _rating = 0;
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        0,
        24,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l.reviewTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(l.rateStars, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  iconSize: 38,
                  tooltip: '$i',
                  onPressed: () => setState(() => _rating = i),
                  icon: Icon(
                    i <= _rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: p.warning,
                  ),
                ),
            ],
          ),
          TextField(
            controller: _text,
            maxLines: 3,
            maxLength: 300,
            decoration: InputDecoration(hintText: l.reviewCommentHint),
          ),
          const SizedBox(height: 8),
          PrimaryButton(
            label: l.submit,
            onPressed: _rating == 0
                ? null
                : () => Navigator.pop(context, (_rating, _text.text.trim())),
          ),
        ],
      ),
    );
  }
}

/// "Book again" starts the wizard with the same doctor.
void repeatFlow(BuildContext context, WidgetRef ref, Appointment a) {
  final doctor = ref.read(doctorLookupProvider)(a.doctorId);
  ref.read(bookingDraftProvider.notifier).start(doctor: doctor);
  context.push('/booking');
}
