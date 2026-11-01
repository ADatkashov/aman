import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';

const supportedLocales = [Locale('kk'), Locale('ru'), Locale('en')];

/// App language. Persisted; defaults to the device language when supported.
class LocaleController extends Notifier<Locale> {
  static const _key = 'aman.locale';

  @override
  Locale build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = prefs.getString(_key);
    final code = saved ?? PlatformDispatcher.instance.locale.languageCode;
    return supportedLocales.firstWhere((l) => l.languageCode == code, orElse: () => const Locale('ru'));
  }

  Future<void> set(Locale locale) async {
    state = locale;
    await ref.read(sharedPreferencesProvider).setString(_key, locale.languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(LocaleController.new);

class ThemeModeController extends Notifier<ThemeMode> {
  static const _key = 'aman.theme';

  @override
  ThemeMode build() {
    final saved = ref.watch(sharedPreferencesProvider).getString(_key);
    return ThemeMode.values.firstWhere((m) => m.name == saved, orElse: () => ThemeMode.system);
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(ThemeModeController.new);

/// Whether the onboarding carousel has been completed.
class OnboardingController extends Notifier<bool> {
  static const _key = 'aman.onboarded';

  @override
  bool build() => ref.watch(sharedPreferencesProvider).getBool(_key) ?? false;

  Future<void> complete() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_key, true);
  }
}

final onboardedProvider = NotifierProvider<OnboardingController, bool>(OnboardingController.new);
