/// A short text available in the three supported languages.
///
/// Used for demo/catalog content (doctor bios, service names, lab test names).
/// Backend responses that only carry a single language use [LocalizedText.plain].
class LocalizedText {
  const LocalizedText({required this.ru, required this.en, required this.kk});

  const LocalizedText.plain(String value)
      : ru = value,
        en = value,
        kk = value;

  final String ru;
  final String en;
  final String kk;

  String of(String languageCode) {
    switch (languageCode) {
      case 'kk':
        return kk;
      case 'en':
        return en;
      default:
        return ru;
    }
  }

  static LocalizedText fromJson(Object? json) {
    if (json is Map) {
      final ru = (json['ru'] ?? json['en'] ?? json['kk'] ?? '') as String;
      return LocalizedText(
        ru: ru,
        en: (json['en'] ?? ru) as String,
        kk: (json['kk'] ?? ru) as String,
      );
    }
    return LocalizedText.plain((json ?? '') as String);
  }

  Map<String, String> toJson() => {'ru': ru, 'en': en, 'kk': kk};

  @override
  bool operator ==(Object other) =>
      other is LocalizedText && other.ru == ru && other.en == en && other.kk == kk;

  @override
  int get hashCode => Object.hash(ru, en, kk);
}
