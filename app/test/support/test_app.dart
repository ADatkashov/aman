import 'dart:typed_data';

import 'package:aman/app.dart';
import 'package:aman/core/providers.dart';
import 'package:aman/core/router/app_router.dart';
import 'package:aman/core/services/file_picker_service.dart';
import 'package:aman/core/services/url_opener.dart';
import 'package:aman/core/widgets/buttons.dart';
import 'package:aman/data/demo/demo_store.dart';
import 'package:aman/features/auth/domain/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Monday, 2 Nov 2026, 09:00 — fixed "now" for deterministic schedules.
final DateTime testNow = DateTime(2026, 11, 2, 9, 0);

class FakeUrlOpener implements UrlOpener {
  final List<Uri> opened = [];

  @override
  Future<bool> open(Uri uri) async {
    opened.add(uri);
    return true;
  }
}

class FakeFilePicker implements FilePickerService {
  FakeFilePicker(this.file);
  PickedFile? file;

  @override
  Future<PickedFile?> pickDocument() async => file;
}

class TestEnv {
  TestEnv({required this.container, required this.opener, required this.store});
  final ProviderContainer container;
  final FakeUrlOpener opener;
  final DemoStore store;
}

Future<void> initTestLocale() async => initializeDateFormatting();

DemoStore newStore() => DemoStore(clock: () => testNow);

/// Builds the overrides used by every widget test.
List<Override> testOverrides({
  required SharedPreferences prefs,
  required DemoStore store,
  required FakeUrlOpener opener,
  TokenStorage? tokens,
  FilePickerService? picker,
}) => [
  sharedPreferencesProvider.overrideWithValue(prefs),
  clockProvider.overrideWithValue(() => testNow),
  demoStoreProvider.overrideWithValue(store),
  tokenStorageProvider.overrideWithValue(tokens ?? MemoryTokenStorage()),
  urlOpenerProvider.overrideWithValue(opener),
  filePickerProvider.overrideWithValue(picker ?? FakeFilePicker(null)),
  splashDoneProvider.overrideWith((ref) async {}),
];

/// Pumps the whole app. Pass [signedIn] to start with a restored session.
Future<TestEnv> pumpApp(
  WidgetTester tester, {
  String locale = 'ru',
  bool signedIn = false,
  bool onboarded = false,
  FilePickerService? picker,
}) async {
  await initTestLocale();
  SharedPreferences.setMockInitialValues({
    'aman.locale': locale,
    'aman.onboarded': onboarded,
  });
  final prefs = await SharedPreferences.getInstance();
  final tokens = MemoryTokenStorage();
  if (signedIn) await tokens.saveTokens(access: 'demo-token:+77000000001');
  final store = newStore();
  final opener = FakeUrlOpener();
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final container = ProviderContainer(
    overrides: testOverrides(
      prefs: prefs,
      store: store,
      opener: opener,
      tokens: tokens,
      picker: picker,
    ),
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(container: container, child: const AmanApp()),
  );
  await settle(tester);
  return TestEnv(container: container, opener: opener, store: store);
}

/// `pumpAndSettle` replacement: skeleton shimmers animate forever.
Future<void> settle(WidgetTester tester, {int frames = 12}) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> tapText(
  WidgetTester tester,
  String text, {
  bool last = false,
}) async {
  final finder = find.text(text);
  expect(finder, findsWidgets, reason: 'text "$text" not found');
  final target = last ? finder.last : finder.first;
  await tester.pump(
    const Duration(milliseconds: 400),
  ); // let focus-scroll animations finish
  await tester.ensureVisible(target);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(target);
  await settle(tester);
}

Uint8List bytes(int n) => Uint8List.fromList(List.filled(n, 1));

/// Taps the only [PrimaryButton] on screen (robust against duplicated labels).
Future<void> tapPrimary(WidgetTester tester) async {
  final finder = find.byType(PrimaryButton).last;
  await tester.pump(const Duration(milliseconds: 400));
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(milliseconds: 400));
  await tester.tap(finder, warnIfMissed: false);
  await settle(tester);
}

/// Navigates through the app router (equivalent to a deep link / push).
Future<void> goTo(TestEnv env, WidgetTester tester, String location) async {
  env.container.read(routerProvider).push(location);
  await settle(tester);
}

/// Scrolls a horizontal list until [finder] is visible.
Future<void> scrollHorizontallyTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    120,
    scrollable: find
        .byWidgetPredicate((w) => w is Scrollable && w.axis == Axis.horizontal)
        .last,
  );
}
