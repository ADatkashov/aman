import 'package:aman/data/demo/demo_patient_seed.dart';
import 'package:aman/data/demo/demo_repositories.dart';
import 'package:aman/data/demo/demo_store.dart';
import 'package:aman/features/auth/domain/auth_repository.dart';
import 'package:aman/features/auth/domain/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  late DemoStore store;
  late MemoryTokenStorage tokens;
  late DemoAuthRepository auth;

  setUp(() {
    store = newStore();
    tokens = MemoryTokenStorage();
    auth = DemoAuthRepository(store, tokens);
  });

  Matcher failsWith(AuthFailure f) => throwsA(isA<AuthException>().having((e) => e.failure, 'failure', f));

  test('login with demo credentials stores a token and restores the session', () async {
    final profile = await auth.login(phone: '700 000 00 01', password: DemoAccount.password);
    expect(profile.firstName, 'Алексей');
    expect(await tokens.readAccessToken(), isNotNull);
    expect((await auth.restoreSession())?.id, profile.id);
  });

  test('wrong password or unknown phone is rejected with the same error', () async {
    await expectLater(auth.login(phone: '+77000000001', password: 'Wrong1234'), failsWith(AuthFailure.invalidCredentials));
    await expectLater(auth.login(phone: '+77011111111', password: 'Demo1234'), failsWith(AuthFailure.invalidCredentials));
    expect(await tokens.readAccessToken(), isNull);
  });

  test('passwords are stored salted and hashed, never in plain text', () async {
    final record = store.accounts['+77000000001']!;
    expect(record.passwordHash, isNot(DemoAccount.password));
    expect(record.passwordHash.length, 64);
    final other = DemoStore.hashPassword(DemoAccount.password, 'another-salt');
    expect(other, isNot(record.passwordHash));
  });

  test('registration requires consent and a verified phone', () async {
    await expectLater(
      auth.register(fullName: 'Ким Алия', phone: '+77012223344', password: 'Secret123', consentAccepted: false),
      failsWith(AuthFailure.consentRequired),
    );
    final code = await auth.register(fullName: 'Ким Алия', phone: '8 701 222 33 44', password: 'Secret123', consentAccepted: true);
    expect(code, DemoAccount.otp);
    // Not signed in until the OTP is confirmed.
    await expectLater(auth.login(phone: '+77012223344', password: 'Secret123'), failsWith(AuthFailure.invalidCredentials));
    await expectLater(auth.confirmPhone(phone: '+77012223344', code: '9999'), failsWith(AuthFailure.invalidOtp));
    final profile = await auth.confirmPhone(phone: '+77012223344', code: code!);
    expect(profile.fullName, 'Ким Алия');
    expect(profile.phone, '+77012223344');
    // After confirmation the new credentials work.
    await auth.logout();
    expect((await auth.login(phone: '+77012223344', password: 'Secret123')).id, profile.id);
  });

  test('cannot register an already registered phone', () async {
    await expectLater(
      auth.register(fullName: 'Дубль Тест', phone: '+77000000001', password: 'Secret123', consentAccepted: true),
      failsWith(AuthFailure.phoneTaken),
    );
  });

  test('password reset with OTP', () async {
    final code = await auth.requestPasswordReset('+77000000001');
    await expectLater(auth.resetPassword(phone: '+77000000001', code: '0000', newPassword: 'NewPass123'), failsWith(AuthFailure.invalidOtp));
    await auth.resetPassword(phone: '+77000000001', code: code!, newPassword: 'NewPass123');
    await expectLater(auth.login(phone: '+77000000001', password: DemoAccount.password), failsWith(AuthFailure.invalidCredentials));
    expect((await auth.login(phone: '+77000000001', password: 'NewPass123')).id, 'p1');
    await expectLater(auth.requestPasswordReset('+77019999999'), failsWith(AuthFailure.accountNotFound));
  });

  test('logout clears tokens', () async {
    await auth.login(phone: '+77000000001', password: DemoAccount.password);
    await auth.logout();
    expect(await tokens.readAccessToken(), isNull);
    expect(await auth.restoreSession(), isNull);
  });

  test('profile update persists', () async {
    final p = await auth.login(phone: '+77000000001', password: DemoAccount.password);
    final updated = await auth.updateProfile(p.copyWith(city: 'Шымкент', email: 'new@example.com'));
    expect(updated.city, 'Шымкент');
    expect(store.accounts['+77000000001']!.profile.email, 'new@example.com');
  });
}
