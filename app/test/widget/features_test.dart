import 'package:aman/core/providers.dart';
import 'package:aman/core/router/app_router.dart';
import 'package:aman/core/services/file_picker_service.dart';
import 'package:aman/features/auth/application/auth_controller.dart';
import 'package:aman/features/catalog/application/catalog_providers.dart';
import 'package:aman/features/catalog/presentation/widgets/doctor_card.dart';
import 'package:aman/features/documents/application/documents_controller.dart';
import 'package:aman/features/settings/application/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

void main() {
  group('doctor catalog', () {
    testWidgets(
      'search, specialty chips and filters narrow the list; empty state can reset',
      (tester) async {
        final env = await pumpApp(tester, signedIn: true);
        await goTo(env, tester, '/doctors');
        expect(find.byType(DoctorCard), findsWidgets);

        await tester.enterText(find.byType(TextField).first, 'кардиолог');
        await settle(tester);
        expect(find.text('Иванова Мария Сергеевна'), findsOneWidget);
        expect(find.text('Смирнов Алексей Иванович'), findsNothing);

        await tester.enterText(find.byType(TextField).first, 'ничегонет');
        await settle(tester);
        expect(find.text('Врачи не найдены'), findsOneWidget);
        await tapText(tester, 'Сбросить фильтры');
        expect(find.text('Врачи не найдены'), findsNothing);
        expect(env.container.read(filteredDoctorsProvider).value!.length, 14);

        await scrollHorizontallyTo(tester, find.text('Стоматолог'));
        await tapText(tester, 'Стоматолог');
        expect(
          env.container.read(doctorFilterProvider).specialty!.name,
          'dentist',
        );
        expect(find.text('Сейтқали Данияр Маратұлы'), findsOneWidget);
        expect(find.text('Смирнов Алексей Иванович'), findsNothing);
        expect(
          env.container
              .read(filteredDoctorsProvider)
              .value!
              .map((d) => d.id)
              .toSet(),
          {'d6', 'd12'},
        );
      },
    );

    testWidgets('filter sheet applies sort and price', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/doctors');
      await tester.tap(find.byTooltip('Фильтры'));
      await settle(tester);
      await tapText(tester, 'Цена: по возрастанию');
      await tapText(tester, 'Применить');
      final f = env.container.read(doctorFilterProvider);
      expect(f.sort.name, 'priceAsc');
      final list = env.container.read(filteredDoctorsProvider).value!;
      expect(
        list.first.priceKzt,
        list.map((d) => d.priceKzt).reduce((a, b) => a < b ? a : b),
      );
    });

    testWidgets('favorites can be toggled and listed', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/doctors/d3');
      expect(
        env.container.read(favoritesProvider).value,
        isNot(contains('d3')),
      );
      await tester.tap(find.byTooltip('В избранное'));
      await settle(tester);
      expect(env.container.read(favoritesProvider).value, contains('d3'));
      expect(find.text('Добавлено в избранное'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));

      env.container.read(routerProvider).push('/favorites');
      await settle(tester);
      expect(find.text('Избранные врачи'), findsOneWidget);
      final shown = env.container
          .read(filteredDoctorsProvider)
          .value!
          .map((d) => d.id)
          .toSet();
      expect(shown, {'d1', 'd2', 'd3', 'd5'});
    });
  });

  group('analyses and record', () {
    testWidgets(
      'list → detail shows laboratory reference ranges, flags and the disclaimer',
      (tester) async {
        final env = await pumpApp(tester, signedIn: true);
        await goTo(env, tester, '/analyses');
        expect(find.text('Мои анализы'), findsOneWidget);
        expect(find.text('Назначения'), findsOneWidget);
        await goTo(env, tester, '/analyses/l4');
        expect(find.text('Общий холестерин'), findsOneWidget);
        expect(find.textContaining('Референсные значения'), findsWidgets);
        expect(
          find.text('Вне референсного диапазона лаборатории'),
          findsOneWidget,
        );
        expect(find.text('В пределах референсного диапазона'), findsWidgets);
        await tester.scrollUntilVisible(
          find.textContaining('не ставит диагнозов'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.textContaining('не ставит диагнозов'), findsOneWidget);
      },
    );

    testWidgets('orders tab lists prescribed tests', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/analyses');
      await tapText(tester, 'Назначения');
      expect(find.text('Липидный профиль'), findsOneWidget);
      expect(find.text('Ожидается'), findsWidgets);
    });

    testWidgets('a dynamics chart is shown for repeated tests', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/analyses/l3');
      expect(find.byType(CustomPaint), findsWidgets);
      expect(find.textContaining('Динамика:'), findsWidgets);
    });

    testWidgets('medical record shows confirmed entries and filters by type', (
      tester,
    ) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/medical-record');
      expect(find.text('Общая информация'), findsOneWidget);
      expect(find.textContaining('Подтверждено:'), findsWidgets);
      await scrollHorizontallyTo(tester, find.text('Вакцинация'));
      await tapText(tester, 'Вакцинация');
      expect(find.text('Вакцинация против гриппа'), findsOneWidget);
      expect(find.text('Приём невролога'), findsNothing);
    });
  });

  group('documents', () {
    testWidgets('uploads a valid PDF', (tester) async {
      final env = await pumpApp(
        tester,
        signedIn: true,
        picker: FakeFilePicker(
          PickedFile(name: 'result.pdf', bytes: bytes(5000)),
        ),
      );
      await goTo(env, tester, '/documents');
      await tester.tap(find.byTooltip('Загрузить документ'));
      await settle(tester);
      await tapText(tester, 'Выберите файл (PDF, JPG, PNG)');
      expect(find.textContaining('result.pdf'), findsWidgets);
      await tapPrimary(tester);
      expect(find.text('Документ загружен'), findsOneWidget);
      expect(
        env.container.read(documentsProvider).value!.first.fileName,
        'result.pdf',
      );
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('rejects an unsupported file type before upload', (
      tester,
    ) async {
      final env = await pumpApp(
        tester,
        signedIn: true,
        picker: FakeFilePicker(PickedFile(name: 'run.exe', bytes: bytes(10))),
      );
      await goTo(env, tester, '/documents');
      await tester.tap(find.byTooltip('Загрузить документ'));
      await settle(tester);
      await tapText(tester, 'Выберите файл (PDF, JPG, PNG)');
      expect(find.text('Допустимы только PDF, JPG и PNG'), findsOneWidget);
      expect(
        env.container
            .read(documentsProvider)
            .value!
            .any((d) => d.fileName == 'run.exe'),
        isFalse,
      );
    });

    testWidgets('rejects a file over 10 MB', (tester) async {
      final env = await pumpApp(
        tester,
        signedIn: true,
        picker: FakeFilePicker(
          PickedFile(name: 'big.pdf', bytes: bytes(10 * 1024 * 1024 + 1)),
        ),
      );
      await goTo(env, tester, '/documents');
      await tester.tap(find.byTooltip('Загрузить документ'));
      await settle(tester);
      await tapText(tester, 'Выберите файл (PDF, JPG, PNG)');
      expect(find.text('Файл больше 10 МБ'), findsOneWidget);
    });

    testWidgets('demo document opens with its synthetic content', (
      tester,
    ) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/documents/doc1');
      expect(find.text('Заключение невролога (DEMO)'), findsOneWidget);
      expect(find.textContaining('ДЕМО-ДОКУМЕНТ'), findsOneWidget);
    });
  });

  group('clinics', () {
    testWidgets(
      'map shows markers; selecting a clinic enables directions via the maps link',
      (tester) async {
        final env = await pumpApp(tester, signedIn: true);
        await goTo(env, tester, '/clinics');
        expect(find.byIcon(Icons.add_rounded), findsWidgets, reason: 'markers');
        expect(find.textContaining('Демонстрационная карта'), findsOneWidget);
        await tester.tap(
          find.bySemanticsLabel(RegExp('Здоровье')).first,
          warnIfMissed: false,
        );
        await settle(tester);
        await tapText(tester, 'Построить маршрут');
        expect(env.opener.opened.single.toString(), contains('2gis.kz'));
      },
    );

    testWidgets('list view, search and details', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/clinics');
      await tester.tap(find.byTooltip('Список'));
      await settle(tester);
      await tester.enterText(find.byType(TextField).first, 'алатау');
      await settle(tester);
      expect(find.textContaining('Алатау'), findsWidgets);
      expect(find.textContaining('Сункар'), findsNothing);
      await goTo(env, tester, '/clinics/c2');
      await tester.scrollUntilVisible(
        find.text('Врачи клиники'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Врачи клиники'), findsOneWidget);
    });
  });

  group('notifications', () {
    testWidgets('mark all as read and delete', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/notifications');
      expect(find.text('Напоминание о приёме'), findsOneWidget);
      expect(env.store.notifications.where((n) => !n.read).length, 2);
      await tester.tap(find.byTooltip('Прочитать все'));
      await settle(tester);
      expect(env.store.notifications.every((n) => n.read), isTrue);
      await tester.tap(find.byTooltip('Удалить уведомление').first);
      await settle(tester);
      expect(env.store.notifications.length, 3);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets('tapping a notification opens its target', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/notifications');
      await tapText(tester, 'Результаты анализов готовы');
      expect(find.text('Биохимический анализ крови'), findsWidgets);
      expect(
        env.store.notifications.firstWhere((n) => n.id == 'n2').read,
        isTrue,
      );
    });
  });

  group('profile and settings', () {
    testWidgets('profile shows stats and edits personal data with validation', (
      tester,
    ) async {
      final env = await pumpApp(tester, signedIn: true);
      await tapText(tester, 'Профиль');
      expect(find.text('Петров Алексей Сергеевич'), findsOneWidget);
      expect(find.text('+7 700 000 00 01'), findsOneWidget);
      await tapText(tester, 'Редактировать');
      expect(find.text('Редактирование профиля'), findsOneWidget);
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Иван');
      await tester.enterText(fields.at(2), 'bad-email');
      await tapPrimary(tester);
      expect(find.text('Укажите фамилию и имя'), findsOneWidget);
      expect(find.text('Введите корректную почту'), findsOneWidget);
      await tester.enterText(fields.at(0), 'Петров Иван Сергеевич');
      await tester.enterText(fields.at(2), 'ivan@example.com');
      await tapPrimary(tester);
      expect(
        env.container.read(authControllerProvider).value!.fullName,
        'Петров Иван Сергеевич',
      );
      expect(find.text('Профиль сохранён'), findsOneWidget);
      await tester.pump(const Duration(seconds: 6));
    });

    testWidgets(
      'logout asks for confirmation and returns to the login screen',
      (tester) async {
        final env = await pumpApp(tester, signedIn: true, onboarded: true);
        await tapText(tester, 'Профиль');
        await tester.scrollUntilVisible(
          find.text('Выйти из аккаунта'),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        await tapText(tester, 'Выйти из аккаунта');
        expect(find.text('Выйти из AMAN?'), findsOneWidget);
        await tapText(tester, 'Отмена');
        expect(env.container.read(authControllerProvider).value, isNotNull);
        await tapText(tester, 'Выйти из аккаунта');
        await tapText(tester, 'Выйти из аккаунта', last: true);
        expect(env.container.read(authControllerProvider).value, isNull);
        expect(find.text('С возвращением'), findsOneWidget);
      },
    );

    testWidgets(
      'language can be switched to Kazakh and English and is persisted',
      (tester) async {
        final env = await pumpApp(tester, signedIn: true);
        expect(find.text('Здравствуйте, Алексей!'), findsOneWidget);
        await env.container
            .read(localeProvider.notifier)
            .set(const Locale('en'));
        await settle(tester);
        expect(find.text('Hello, Алексей!'), findsOneWidget);
        expect(find.text('Quick services'), findsOneWidget);
        await env.container
            .read(localeProvider.notifier)
            .set(const Locale('kk'));
        await settle(tester);
        expect(find.text('Сәлеметсіз бе, Алексей!'), findsOneWidget);
        expect(find.text('Жылдам сервистер'), findsOneWidget);
        expect(
          env.container
              .read(sharedPreferencesProvider)
              .getString('aman.locale'),
          'kk',
        );
      },
    );

    testWidgets('settings screen switches language via radio and theme', (
      tester,
    ) async {
      final env = await pumpApp(tester, signedIn: true);
      await goTo(env, tester, '/settings');
      await tapText(tester, 'English');
      expect(env.container.read(localeProvider).languageCode, 'en');
      expect(find.text('Settings'), findsWidgets);
      await tapText(tester, 'Dark');
      expect(env.container.read(themeModeProvider), ThemeMode.dark);
    });
  });

  group('responsiveness and accessibility', () {
    for (final size in const [
      Size(320, 640),
      Size(360, 800),
      Size(430, 932),
      Size(768, 1024),
    ]) {
      testWidgets(
        'home and tabs render without overflow at ${size.width.toInt()}x${size.height.toInt()}',
        (tester) async {
          final env = await pumpApp(tester, signedIn: true, locale: 'kk');
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1;
          await settle(tester);
          for (final path in [
            '/home',
            '/appointments',
            '/services',
            '/profile',
          ]) {
            env.container.read(routerProvider).go(path);
            await settle(tester);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('large text scale keeps the home screen usable', (
      tester,
    ) async {
      await pumpApp(tester, signedIn: true);
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await settle(tester);
      expect(find.text('Здравствуйте, Алексей!'), findsOneWidget);
    });

    testWidgets('dark theme renders', (tester) async {
      final env = await pumpApp(tester, signedIn: true);
      await env.container.read(themeModeProvider.notifier).set(ThemeMode.dark);
      await settle(tester);
      expect(
        Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
        Brightness.dark,
      );
    });

    testWidgets('interactive elements expose semantics labels', (tester) async {
      await pumpApp(tester, signedIn: true);
      final handle = tester.ensureSemantics();
      expect(find.bySemanticsLabel('Уведомления'), findsWidgets);
      expect(find.bySemanticsLabel(RegExp('Главная')), findsWidgets);
      handle.dispose();
    });
  });
}
