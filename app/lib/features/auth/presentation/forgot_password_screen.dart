import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';
import 'otp_screen.dart';

/// Two-step password recovery (also used by "Change password").
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialPhone});

  final String? initialPhone;

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneForm = GlobalKey<FormState>();
  final _resetForm = GlobalKey<FormState>();
  late final TextEditingController _phone = TextEditingController(text: widget.initialPhone ?? '');
  final _code = TextEditingController();
  final _password = TextEditingController();
  bool _codeSent = false;
  bool _loading = false;
  String? _demoCode;

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(context.l10n, e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendCode() async {
    if (!_phoneForm.currentState!.validate()) return;
    await _run(() async {
      final code = await ref.read(authControllerProvider.notifier).requestPasswordReset(_phone.text);
      setState(() {
        _codeSent = true;
        _demoCode = code;
      });
    });
  }

  Future<void> _reset() async {
    if (!_resetForm.currentState!.validate()) return;
    await _run(() async {
      await ref.read(authControllerProvider.notifier).resetPassword(_phone.text, _code.text, _password.text);
      if (!mounted) return;
      showSnack(context, context.l10n.passwordResetDone);
      context.pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return AuthScaffold(
      title: l.resetTitle,
      subtitle: l.resetSubtitle,
      child: _codeSent
          ? Form(
              key: _resetForm,
              child: Column(
                children: [
                  OtpEntry(
                    controller: _code,
                    onResend: () async {
                      final code = await ref.read(authControllerProvider.notifier).requestPasswordReset(_phone.text);
                      if (mounted) setState(() => _demoCode = code);
                    },
                  ),
                  if (_demoCode != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(children: [
                        const DemoTag(),
                        const SizedBox(width: 8),
                        Expanded(child: Text(l.otpDemoHint(_demoCode!), style: Theme.of(context).textTheme.bodySmall)),
                      ]),
                    ),
                  PasswordField(controller: _password, label: l.newPasswordLabel, onSubmitted: (_) => _reset()),
                  const SizedBox(height: 20),
                  PrimaryButton(label: l.resetButton, onPressed: _reset, loading: _loading),
                ],
              ),
            )
          : Form(
              key: _phoneForm,
              child: Column(
                children: [
                  KzPhoneField(controller: _phone),
                  const SizedBox(height: 20),
                  PrimaryButton(label: l.sendCode, onPressed: _sendCode, loading: _loading),
                ],
              ),
            ),
    );
  }
}
