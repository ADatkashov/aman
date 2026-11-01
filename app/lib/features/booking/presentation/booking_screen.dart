import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../appointments/domain/appointment.dart';
import '../application/booking_draft.dart';
import 'booking_steps.dart';

/// Seven-step booking wizard. Selections live in [bookingDraftProvider].
class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  static const _stepCount = 7;
  final _reasonForm = GlobalKey<FormState>();
  late int _step = _initialStep(ref.read(bookingDraftProvider));
  bool _submitting = false;

  /// Jump over steps that were pre-filled by the entry point.
  static int _initialStep(BookingDraft d) {
    if (d.doctor == null) return d.specialty == null ? 0 : 1;
    if (d.slot != null) return 5;
    return 3;
  }

  bool get _canContinue {
    final d = ref.read(bookingDraftProvider);
    return switch (_step) {
      0 => d.specialty != null,
      1 => d.doctor != null,
      2 => true,
      3 => d.date != null,
      4 => d.slot != null,
      5 => d.reason.trim().length >= 3,
      _ => true,
    };
  }

  void _go(int step) => setState(() => _step = step.clamp(0, _stepCount - 1));

  void _next() {
    if (_step == 5 && !(_reasonForm.currentState?.validate() ?? false)) return;
    if (_step < _stepCount - 1) _go(_step + 1);
  }

  Future<bool> _confirmLeave() async {
    final l = context.l10n;
    return confirmAction(
      context,
      title: l.bookingCancelTitle,
      body: l.bookingCancelBody,
      confirmLabel: l.leave,
      destructive: true,
    );
  }

  Future<void> _submit() async {
    final l = context.l10n;
    setState(() => _submitting = true);
    try {
      final id = await confirmBooking(ref);
      if (mounted) context.go('/booking/success/$id');
    } catch (e) {
      if (!mounted) return;
      showSnack(context, errorMessage(l, e), error: true);
      if (e is BookingException &&
          (e.failure == BookingFailure.slotTaken ||
              e.failure == BookingFailure.slotInPast ||
              e.failure == BookingFailure.outsideSchedule)) {
        ref.invalidate(slotsProvider);
        ref
            .read(bookingDraftProvider.notifier)
            .pickDate(ref.read(bookingDraftProvider).date!);
        _go(4);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    ref.watch(bookingDraftProvider); // rebuild when selections change
    ref.watch(clinicsProvider);

    final headings = [
      l.chooseSpecialty,
      l.chooseDoctor,
      l.chooseClinic,
      l.chooseDate,
      l.chooseTime,
      l.reasonLabel,
      l.stepConfirm,
    ];
    final isLast = _step == _stepCount - 1;

    final body = switch (_step) {
      0 => SpecialtyStep(onPicked: _next),
      1 => DoctorStep(onPicked: _next),
      2 => const ClinicStep(),
      3 => DateStep(onPicked: _next),
      4 => const TimeStep(),
      5 => ReasonStep(formKey: _reasonForm),
      _ => const ConfirmStep(),
    };

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (_step > 0) {
          _go(_step - 1);
          return;
        }
        if (await _confirmLeave() && context.mounted) context.pop();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: l.bookingTitle,
          onBack: () async {
            if (_step > 0) {
              _go(_step - 1);
            } else if (await _confirmLeave() && context.mounted) {
              context.pop();
            }
          },
          actions: [
            AmanIconButton(
              icon: Icons.close_rounded,
              tooltip: l.close,
              onPressed: () async {
                if (await _confirmLeave() && context.mounted) context.pop();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      for (var i = 0; i < _stepCount; i++)
                        Expanded(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            height: 5,
                            margin: EdgeInsets.only(
                              right: i == _stepCount - 1 ? 0 : 5,
                            ),
                            decoration: BoxDecoration(
                              color: i <= _step ? p.primary : p.border,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l.stepOf(_step + 1, _stepCount), style: t.bodySmall),
                  Text(headings[_step], style: t.headlineSmall),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                switchInCurve: Curves.easeOutCubic,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.06, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_step), child: body),
              ),
            ),
            BottomActionBar(
              child: PrimaryButton(
                label: isLast ? l.confirmBooking : l.continueAction,
                loading: _submitting,
                onPressed: !_canContinue ? null : (isLast ? _submit : _next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
