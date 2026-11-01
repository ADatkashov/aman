import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class OtpArgs {
  const OtpArgs({required this.phone, this.demoCode});
  final String phone;
  final String? demoCode;
}

/// Reusable 4-digit code input with resend countdown.
class OtpEntry extends StatefulWidget {
  const OtpEntry({super.key, required this.controller, required this.onResend, this.onSubmitted});

  final TextEditingController controller;
  final Future<void> Function() onResend;
  final VoidCallback? onSubmitted;

  @override
  State<OtpEntry> createState() => _OtpEntryState();
}

class _OtpEntryState extends State<OtpEntry> {
  static const _cooldown = 30;
  int _left = _cooldown;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _timer?.cancel();
    setState(() => _left = _cooldown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _left--);
      if (_left <= 0) t.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          autofocus: true,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 4,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: const TextStyle(fontSize: 34, letterSpacing: 18, fontWeight: FontWeight.w800),
          decoration: InputDecoration(counterText: '', hintText: '••••', labelText: l.otpLabel),
          onFieldSubmitted: (_) => widget.onSubmitted?.call(),
          validator: (v) => Validators.otp(v)?.message(l),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: _left > 0
              ? null
              : () async {
                  await widget.onResend();
                  _start();
                },
          child: Text(
            _left > 0 ? '${l.resendCode} · 0:${_left.toString().padLeft(2, '0')}' : l.resendCode,
            style: TextStyle(color: _left > 0 ? p.textSecondary : p.primary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.args});
  final OtpArgs args;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  bool _loading = false;
  String? _demoCode;

  @override
  void initState() {
    super.initState();
    _demoCode = widget.args.demoCode;
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).confirmPhone(widget.args.phone, _code.text);
      if (mounted) context.go('/profile-setup');
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(context.l10n, e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final normalized = KzPhone.normalize(widget.args.phone);
    final shown = normalized == null ? widget.args.phone : KzPhone.format(normalized);
    return AuthScaffold(
      title: l.otpTitle,
      subtitle: l.otpSubtitle(shown),
      child: Form(
        key: _form,
        child: Column(
          children: [
            OtpEntry(
              controller: _code,
              onSubmitted: _verify,
              onResend: () async {
                final code = await ref.read(authControllerProvider.notifier).resendOtp(widget.args.phone);
                if (!context.mounted) return;
                setState(() => _demoCode = code);
                showSnack(context, l.codeResent);
              },
            ),
            if (_demoCode != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const DemoTag(),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l.otpDemoHint(_demoCode!), style: Theme.of(context).textTheme.bodySmall)),
                ],
              ),
            ],
            const SizedBox(height: 24),
            PrimaryButton(label: l.verify, onPressed: _verify, loading: _loading),
          ],
        ),
      ),
    );
  }
}
