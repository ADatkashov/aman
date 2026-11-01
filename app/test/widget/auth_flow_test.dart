import 'package:aman/data/demo/demo_patient_seed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  testWidgets(
    'first launch shows onboarding, then login with the demo account reaches Home',
    (tester) async {
      await pumpApp(tester);
      expect(find.textContaining('Здоровье'), findsWidgets);
      await tapText(tester, 'Далее');
      await tapText(tester, 'Далее');
      await tapText(tester, 'Далее');
      expect(find.text('Начать'), findsOneWidget);
      await tapText(tester, 'У меня уже есть аккаунт');
      expect(find.text('С возвращением'), findsOneWidget);

      await tapText(tester, 'Подставить демо-аккаунт');
      await tapText(tester, 'Войти', last: true);
      expect(find.text('Здравствуйте, Алексей!'), findsOneWidget);
      expect(find.text('Ближайшая запись'), findsOneWidget);
    },
  );

  testWidgets(
    'login validates empty fields and shows an error for wrong credentials',
    (tester) async {
      await pumpApp(tester, onboarded: true);
      expect(find.text('С возвращением'), findsOneWidget);
      await tapText(tester, 'Войти', last: true);
      expect(find.text('Обязательное поле'), findsWidgets);

      await tester.enterText(find.byType(TextFormField).first, '7000000001');
      await tester.enterText(find.byType(TextFormField).last, 'WrongPass1');
      await tapText(tester, 'Войти', last: true);
      expect(find.text('Неверный номер телефона или пароль'), findsOneWidget);
    },
  );

  testWidgets(
    'registration requires valid data and consent, then OTP and profile setup',
    (tester) async {
      final env = await pumpApp(tester, onboarded: true);
      await tapText(tester, 'Создать аккаунт');
      expect(find.text('Создайте аккаунт'), findsOneWidget);

      // Empty submit -> field errors + consent error.
      await tapPrimary(tester);
      expect(find.text('Обязательное поле'), findsWidgets);
      expect(
        find.text('Необходимо согласие на обработку данных'),
        findsOneWidget,
      );

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Ким Алия');
      await tester.enterText(fields.at(1), '7012223344');
      await tester.enterText(fields.at(2), 'weak');
      await tester.enterText(fields.at(3), 'weak');
      await tapPrimary(tester);
      expect(find.text('Минимум 8 символов, буква и цифра'), findsOneWidget);

      await tester.enterText(fields.at(2), 'Secret123');
      await tester.enterText(fields.at(3), 'Secret124');
      await tapPrimary(tester);
      expect(find.text('Пароли не совпадают'), findsOneWidget);

      await tester.enterText(fields.at(3), 'Secret123');
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tapPrimary(tester);

      // OTP screen with the DEMO hint.
      expect(find.text('Подтвердите телефон'), findsOneWidget);
      expect(find.textContaining(DemoAccount.otp), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '9999');
      await tapText(tester, 'Подтвердить');
      expect(find.text('Неверный код подтверждения'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6)); // snackbar timeout
      await tester.pump(const Duration(seconds: 1));
      await tester.enterText(find.byType(TextFormField), DemoAccount.otp);
      await tapText(tester, 'Подтвердить');

      // Profile setup, then skip to Home.
      expect(find.text('Расскажите о себе'), findsOneWidget);
      expect(env.store.accounts['+77012223344']!.verified, isTrue);
      await tapText(tester, 'Пропустить');
      expect(find.text('Здравствуйте, Алия!'), findsOneWidget);
      // Cancel pending timers of the OTP screen by letting time pass.
      await tester.pump(const Duration(seconds: 31));
    },
  );

  testWidgets('password reset flow through OTP', (tester) async {
    final env = await pumpApp(tester, onboarded: true);
    await tapText(tester, 'Забыли пароль?');
    expect(find.text('Восстановление пароля'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '7000000001');
    await tapText(tester, 'Отправить код');
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), DemoAccount.otp);
    await tester.enterText(fields.at(1), 'NewPass123');
    await tapText(tester, 'Сохранить новый пароль');
    expect(find.text('С возвращением'), findsOneWidget);
    expect(
      env.store.accounts['+77000000001']!.passwordHash,
      isNot(equals(env.store.accounts['+77000000001']!.salt)),
    );
    await tester.pump(const Duration(seconds: 31));
  });
}
