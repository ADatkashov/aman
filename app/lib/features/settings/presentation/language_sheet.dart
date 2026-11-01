import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../application/settings_providers.dart';

const _names = {'kk': 'Қазақша', 'ru': 'Русский', 'en': 'English'};

Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (_) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);
    final p = context.palette;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.languageMenu,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            for (final locale in supportedLocales)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  _names[locale.languageCode]!,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: locale == current
                    ? Icon(Icons.check_circle_rounded, color: p.primary)
                    : null,
                onTap: () {
                  ref.read(localeProvider.notifier).set(locale);
                  Navigator.pop(context);
                },
              ),
          ],
        ),
      ),
    );
  }
}
