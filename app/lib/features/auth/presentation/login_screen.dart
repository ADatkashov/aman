import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../../data/demo/demo_patient_seed.dart';
import '../application/auth_controller.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(_phone.text, _password.text);
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(context.l10n, e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _fillDemo() {
    _phone.text = KzPhone.maskNational(KzPhone.nationalDigits(DemoAccount.phone));
    _password.text = DemoAccount.password;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final isDemo = ref.watch(appConfigProvider).isDemo;
    return AuthScaffold(
      title: l.loginTitle,
      subtitle: l.loginSubtitle,
      showBack: false,
      child: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            KzPhoneField(controller: _phone),
            const SizedBox(height: 16),
            PasswordField(
              controller: _password,
              label: l.passwordLabel,
              validator: (v) => Validators.required(v),
              onSubmitted: (_) => _submit(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/forgot'),
                child: Text(l.forgotPassword, style: TextStyle(color: p.primary, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: l.signIn, onPressed: _submit, loading: _loading),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(l.noAccount, style: Theme.of(context).textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.push('/register'),
                  child: Text(l.signUp, style: TextStyle(color: p.primary, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            if (isDemo) ...[
              const SizedBox(height: 12),
              AmanCard2(
                onTap: _fillDemo,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const DemoTag(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l.demoAccountHint(DemoAccount.password, KzPhone.format(DemoAccount.phone)),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(l.useDemoAccount, style: TextStyle(color: p.primary, fontWeight: FontWeight.w700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Lightweight tappable tinted container (no shadow) for hints.
class AmanCard2 extends StatelessWidget {
  const AmanCard2({super.key, required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: p.lightBlue,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(14), child: child),
      ),
    );
  }
}
