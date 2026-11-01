import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/utils/phone.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/inputs.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/domain/patient_profile.dart';
import '../../auth/presentation/profile_setup_screen.dart'
    show BirthDateField, GenderSelector;

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final PatientProfile _initial = ref.read(authControllerProvider).value!;
  late final _name = TextEditingController(text: _initial.fullName);
  late final _email = TextEditingController(text: _initial.email ?? '');
  late final _city = TextEditingController(text: _initial.city ?? '');
  late final _blood = TextEditingController(text: _initial.bloodType ?? '');
  late DateTime? _birth = _initial.birthDate;
  late Gender _gender = _initial.gender;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _city.dispose();
    _blood.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final l = context.l10n;
    setState(() => _saving = true);
    try {
      await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            _initial.copyWith(
              fullName: _name.text.trim(),
              email: _email.text.trim().isEmpty ? null : _email.text.trim(),
              birthDate: _birth,
              gender: _gender,
              city: _city.text.trim().isEmpty ? null : _city.text.trim(),
              bloodType: _blood.text.trim().isEmpty ? null : _blood.text.trim(),
            ),
          );
      if (!mounted) return;
      showSnack(context, l.profileSaved);
      context.pop();
    } catch (e) {
      if (mounted) showSnack(context, errorMessage(l, e), error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      appBar: CustomAppBar(title: l.editProfileTitle),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    AmanTextField(
                      label: l.fullNameLabel,
                      controller: _name,
                      validator: Validators.fullName,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 16),
                    AmanTextField(
                      label: l.phoneLabel,
                      controller: TextEditingController(
                        text: KzPhone.format(_initial.phone),
                      ),
                      enabled: false,
                    ),
                    const SizedBox(height: 16),
                    AmanTextField(
                      label: l.emailLabel,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.optionalEmail,
                    ),
                    const SizedBox(height: 16),
                    BirthDateField(
                      value: _birth,
                      onChanged: (d) => setState(() => _birth = d),
                    ),
                    const SizedBox(height: 16),
                    GenderSelector(
                      value: _gender,
                      onChanged: (g) => setState(() => _gender = g),
                    ),
                    const SizedBox(height: 16),
                    AmanTextField(label: l.cityLabel, controller: _city),
                    const SizedBox(height: 16),
                    AmanTextField(
                      label: l.bloodTypeLabel,
                      controller: _blood,
                      maxLength: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          BottomActionBar(
            child: PrimaryButton(
              label: l.save,
              loading: _saving,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}
