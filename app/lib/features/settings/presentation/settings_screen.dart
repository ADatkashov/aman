import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/providers.dart';
import '../../../core/services/url_opener.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../auth/application/auth_controller.dart';
import '../application/settings_providers.dart';

const _langNames = {'kk': 'Қазақша', 'ru': 'Русский', 'en': 'English'};

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    final modes = {ThemeMode.system: l.themeSystem, ThemeMode.light: l.themeLight, ThemeMode.dark: l.themeDark};

    return Scaffold(
      appBar: CustomAppBar(title: l.settingsMenu),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(l.languageMenu, style: t.titleMedium),
          const SizedBox(height: 10),
          AmanCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: RadioGroup<String>(
              groupValue: locale.languageCode,
              onChanged: (v) {
                if (v == null) return;
                ref.read(localeProvider.notifier).set(Locale(v));
              },
              child: Column(
                children: [
                  for (final loc in supportedLocales)
                    RadioListTile<String>(
                      value: loc.languageCode,
                      activeColor: p.primary,
                      title: Text(_langNames[loc.languageCode]!, style: t.titleSmall),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(l.appearance, style: t.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ThemeMode>(
              showSelectedIcon: false,
              segments: [for (final e in modes.entries) ButtonSegment(value: e.key, label: Text(e.value))],
              selected: {mode},
              onSelectionChanged: (s) => ref.read(themeModeProvider.notifier).set(s.first),
            ),
          ),
          if (ref.watch(appConfigProvider).isDemo) ...[
            const SizedBox(height: 22),
            Row(children: [
              const DemoTag(),
              const SizedBox(width: 8),
              Expanded(child: Text(l.demoModeNote, style: t.bodySmall)),
            ]),
          ],
        ],
      ),
    );
  }
}

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final profile = ref.watch(authControllerProvider).value;

    Widget info(IconData icon, String title, String body) => AmanCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: p.success.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: p.success),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(title, style: t.titleSmall), const SizedBox(height: 4), Text(body, style: t.bodyMedium)],
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: CustomAppBar(title: l.securityMenu),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          info(Icons.lock_rounded, l.securityTokensTitle, l.securityTokensBody),
          const SizedBox(height: 12),
          info(Icons.verified_user_rounded, l.securityConsentTitle, l.securityConsentBody),
          const SizedBox(height: 18),
          SecondaryButton(
            icon: Icons.password_rounded,
            label: l.changePassword,
            onPressed: profile == null ? null : () => context.push('/forgot', extra: profile.phone),
          ),
        ],
      ),
    );
  }
}

class HelpScreen extends ConsumerWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final faqs = [(l.faq1Q, l.faq1A), (l.faq2Q, l.faq2A), (l.faq3Q, l.faq3A)];
    return Scaffold(
      appBar: CustomAppBar(title: l.helpMenu),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          Text(l.helpFaqTitle, style: t.titleMedium),
          const SizedBox(height: 10),
          AmanCard(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              children: [
                for (final f in faqs)
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      title: Text(f.$1, style: t.titleSmall),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      expandedCrossAxisAlignment: CrossAxisAlignment.start,
                      children: [Text(f.$2, style: t.bodyMedium)],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SecondaryButton(
            icon: Icons.mail_rounded,
            label: l.contactSupport,
            onPressed: () async {
              final ok = await ref.read(urlOpenerProvider).open(Uri(scheme: 'mailto', path: l.supportEmail));
              if (!ok && context.mounted) showSnack(context, l.errorGeneric, error: true);
            },
          ),
          const SizedBox(height: 18),
          Center(child: Text(l.appVersion('1.0.0'), style: t.bodySmall)),
          const SizedBox(height: 6),
          if (ref.watch(appConfigProvider).isDemo)
            Text(l.demoModeNote, textAlign: TextAlign.center, style: t.bodySmall?.copyWith(color: p.textSecondary)),
        ],
      ),
    );
  }
}
