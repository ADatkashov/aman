import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens external links (maps, calendar, phone). Abstracted for tests.
abstract class UrlOpener {
  Future<bool> open(Uri uri);
}

class SystemUrlOpener implements UrlOpener {
  const SystemUrlOpener();

  @override
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

final urlOpenerProvider = Provider<UrlOpener>((ref) => const SystemUrlOpener());
