import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../domain/patient_profile.dart';

/// Holds the signed-in patient (or `null`). Loading state = session restore.
class AuthController extends AsyncNotifier<PatientProfile?> {
  @override
  Future<PatientProfile?> build() =>
      ref.watch(authRepositoryProvider).restoreSession();

  Future<void> login(String phone, String password) async {
    final profile = await ref
        .read(authRepositoryProvider)
        .login(phone: phone, password: password);
    state = AsyncData(profile);
  }

  Future<String?> register({
    required String fullName,
    required String phone,
    required String password,
    required bool consent,
  }) => ref
      .read(authRepositoryProvider)
      .register(
        fullName: fullName,
        phone: phone,
        password: password,
        consentAccepted: consent,
      );

  Future<String?> resendOtp(String phone) =>
      ref.read(authRepositoryProvider).requestOtp(phone);

  Future<void> confirmPhone(String phone, String code) async {
    final profile = await ref
        .read(authRepositoryProvider)
        .confirmPhone(phone: phone, code: code);
    state = AsyncData(profile);
  }

  Future<String?> requestPasswordReset(String phone) =>
      ref.read(authRepositoryProvider).requestPasswordReset(phone);

  Future<void> resetPassword(String phone, String code, String newPassword) =>
      ref
          .read(authRepositoryProvider)
          .resetPassword(phone: phone, code: code, newPassword: newPassword);

  Future<void> updateProfile(PatientProfile profile) async {
    final updated = await ref
        .read(authRepositoryProvider)
        .updateProfile(profile);
    state = AsyncData(updated);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }
}

final authControllerProvider =
    AsyncNotifierProvider<AuthController, PatientProfile?>(AuthController.new);

/// Id of the signed-in patient; data providers watch it so that they reload
/// (and never leak data) when the account changes.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(authControllerProvider.select((v) => v.value?.id)),
);
