import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';
import 'otp_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _consent = false;
  bool _consentError = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _form.currentState!.validate();
    setState(() => _consentError = !_consent);
    if (!valid || !_consent) return;
    setState(() => _loading = true);
    try {
      final demoCode = await ref.read(authControllerProvider.notifier).register(
            fullName: _name.text,
            phone: _phone.text,
            password: _password.text,
            consent: _consent,
          );
      if (mounted) context.push('/otp', extra: OtpArgs(phone: _phone.text, demoCode: demoCode));
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(context.l10n, e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return AuthScaffold(
      title: l.registerTitle,
      subtitle: l.registerSubtitle,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AmanTextField(
              label: l.fullNameLabel,
              hint: l.fullNameHint,
              controller: _name,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              validator: Validators.fullName,
            ),
            const SizedBox(height: 16),
            KzPhoneField(controller: _phone),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              label: l.passwordLabel,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            PasswordField(
              controller: _confirm,
              label: l.confirmPasswordLabel,
              validator: (v) => Validators.confirmPassword(v, _password.text),
            ),
            const SizedBox(height: 16),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _consent = !_consent;
                _consentError = false;
              }),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _consent,
                    onChanged: (v) => setState(() {
                      _consent = v ?? false;
                      _consentError = false;
                    }),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.consentText, style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 4),
                          Text(l.consentNote, style: Theme.of(context).textTheme.bodySmall),
                          if (_consentError)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(l.errConsent, style: TextStyle(color: p.error, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            PrimaryButton(label: l.signUp, onPressed: _submit, loading: _loading),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => context.go('/login'),
                child: Text(l.haveAccount, style: TextStyle(color: p.primary, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
