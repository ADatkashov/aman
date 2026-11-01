import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../settings/application/settings_providers.dart';
import '../application/auth_controller.dart';
import '../domain/patient_profile.dart';
import 'auth_widgets.dart';

/// Shared date-of-birth picker field.
class BirthDateField extends StatelessWidget {
  const BirthDateField({super.key, required this.value, required this.onChanged});

  final DateTime? value;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(l.birthDateLabel,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: p.textSecondary)),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime(now.year - 30),
              firstDate: DateTime(1900),
              lastDate: now,
            );
            if (picked != null) onChanged(picked);
          },
          child: InputDecorator(
            decoration: InputDecoration(suffixIcon: Icon(Icons.calendar_month_rounded, color: p.primary)),
            child: Text(
              value == null ? '—' : context.fmt.dayMonthYear(value!),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ],
    );
  }
}

class GenderSelector extends StatelessWidget {
  const GenderSelector({super.key, required this.value, required this.onChanged});

  final Gender value;
  final ValueChanged<Gender> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(l.genderLabel, style: Theme.of(context).textTheme.labelMedium?.copyWith(color: p.textSecondary)),
        ),
        SizedBox(
          width: double.infinity,
          child: SegmentedButton<Gender>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: Gender.male, label: Text(l.male)),
              ButtonSegment(value: Gender.female, label: Text(l.female)),
            ],
            selected: {value},
            onSelectionChanged: (s) => onChanged(s.first),
          ),
        ),
      ],
    );
  }
}

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _city = TextEditingController();
  DateTime? _birth;
  Gender _gender = Gender.male;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _city.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final profile = ref.read(authControllerProvider).value;
    if (profile == null) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).updateProfile(profile.copyWith(
            birthDate: _birth,
            gender: _gender,
            email: _email.text.trim().isEmpty ? null : _email.text.trim(),
            city: _city.text.trim().isEmpty ? null : _city.text.trim(),
          ));
      await ref.read(onboardedProvider.notifier).complete();
      if (mounted) context.go('/home');
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
      title: l.profileSetupTitle,
      subtitle: l.profileSetupSubtitle,
      showBack: false,
      child: Form(
        key: _form,
        child: Column(
          children: [
            BirthDateField(value: _birth, onChanged: (d) => setState(() => _birth = d)),
            const SizedBox(height: 16),
            GenderSelector(value: _gender, onChanged: (g) => setState(() => _gender = g)),
            const SizedBox(height: 16),
            AmanTextField(label: l.cityLabel, controller: _city, textInputAction: TextInputAction.next),
            const SizedBox(height: 16),
            AmanTextField(
              label: l.emailOptionalLabel,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.optionalEmail,
            ),
            const SizedBox(height: 24),
            PrimaryButton(label: l.finish, onPressed: _save, loading: _loading),
            TextButton(
              onPressed: () => context.go('/home'),
              child: Text(l.skip, style: TextStyle(color: p.textSecondary, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}
