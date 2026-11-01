import 'dart:convert';
import 'dart:io';

import 'package:aman/core/utils/formatters.dart';
import 'package:aman/core/utils/localized_text.dart';
import 'package:aman/l10n/app_localizations.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_app.dart';

Map<String, dynamic> _arb(String lang) =>
    jsonDecode(File('lib/l10n/app_$lang.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  setUpAll(initTestLocale);

  test('all three languages define exactly the same keys', () {
    Set<String> keys(String l) =>
        _arb(l).keys.where((k) => !k.startsWith('@')).toSet();
    final en = keys('en');
    expect(keys('ru'), en, reason: 'ru differs from en');
    expect(keys('kk'), en, reason: 'kk differs from en');
    expect(en.length, greaterThan(400));
  });

  test('no empty translations', () {
    for (final lang in ['en', 'ru', 'kk']) {
      _arb(lang).forEach((k, v) {
        if (!k.startsWith('@') && v is String) {
          expect(v.trim(), isNotEmpty, reason: '$lang:$k');
        }
      });
    }
  });

  test('placeholders are consistent across languages', () {
    final re = RegExp(r'\{(\w+)');
    final en = _arb('en');
    for (final lang in ['ru', 'kk']) {
      final other = _arb(lang);
      for (final k in en.keys.where((k) => !k.startsWith('@'))) {
        final a = re
            .allMatches(en[k] as String)
            .map((m) => m.group(1))
            .where((p) => p != 'plural')
            .toSet();
        final b = re
            .allMatches(other[k] as String)
            .map((m) => m.group(1))
            .where((p) => p != 'plural')
            .toSet();
        expect(b, a, reason: '$lang:$k');
      }
    }
  });

  test('supported locales and lookups', () {
    expect(AppL10n.supportedLocales.map((l) => l.languageCode).toSet(), {
      'kk',
      'ru',
      'en',
    });
    expect(lookupAppL10n(const Locale('en')).navHome, 'Home');
    expect(lookupAppL10n(const Locale('ru')).navHome, 'Главная');
    expect(lookupAppL10n(const Locale('kk')).navHome, 'Басты бет');
  });

  test('ICU plurals follow each language rules', () {
    final ru = lookupAppL10n(const Locale('ru'));
    expect(ru.experienceYears(1), 'Стаж 1 год');
    expect(ru.experienceYears(3), 'Стаж 3 года');
    expect(ru.experienceYears(12), 'Стаж 12 лет');
    expect(ru.reviewsCount(21), '21 отзыв');
    final en = lookupAppL10n(const Locale('en'));
    expect(en.experienceYears(1), '1 year of experience');
    expect(en.experienceYears(5), '5 years of experience');
    expect(
      lookupAppL10n(const Locale('kk')).experienceYears(7),
      '7 жыл тәжірибе',
    );
  });

  test('money is formatted in KZT per locale', () {
    expect(AmanFormat('ru').money(12000), '12 000 ₸');
    expect(AmanFormat('en').money(12000), '₸12,000');
    expect(AmanFormat('kk').money(1500), contains('₸'));
  });

  test('dates are localized', () {
    final d = DateTime(2026, 11, 4, 15, 30);
    expect(AmanFormat('ru').dayMonth(d), '4 ноября');
    expect(AmanFormat('en').dayMonth(d), 'November 4');
    expect(AmanFormat('kk').dayMonth(d), contains('қараша'));
    expect(AmanFormat('ru').time(d), '15:30');
  });

  test('LocalizedText picks the language and falls back to ru', () {
    const t = LocalizedText(ru: 'а', en: 'b', kk: 'в');
    expect(t.of('en'), 'b');
    expect(t.of('kk'), 'в');
    expect(t.of('de'), 'а');
    expect(LocalizedText.fromJson('x').of('kk'), 'x');
    expect(LocalizedText.fromJson({'ru': 'р', 'en': 'e'}).of('kk'), 'р');
  });
}
