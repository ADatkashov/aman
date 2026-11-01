import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_logo.dart';
import '../../../core/widgets/buttons.dart';
import '../../settings/application/settings_providers.dart';
import '../../settings/presentation/language_sheet.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final pages = [
      (Icons.health_and_safety_rounded, l.welcomeTitle, l.welcomeSubtitle),
      (Icons.person_search_rounded, l.onb1Title, l.onb1Body),
      (Icons.event_available_rounded, l.onb2Title, l.onb2Body),
      (Icons.lock_rounded, l.onb3Title, l.onb3Body),
    ];
    return Scaffold(
      backgroundColor: p.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
              child: Row(
                children: [
                  const AmanLogo(size: 34),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => showLanguageSheet(context),
                    icon: const Icon(Icons.language_rounded, size: 20),
                    label: Text(
                      ref.watch(localeProvider).languageCode.toUpperCase(),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) {
                  final (icon, title, body) = pages[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [p.lightBlue, p.surface],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: p.primary.withValues(alpha: 0.14),
                                blurRadius: 40,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Icon(icon, size: 96, color: p.primary),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: i == 0 ? t.displaySmall : t.headlineMedium,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          body,
                          textAlign: TextAlign.center,
                          style: t.bodyLarge?.copyWith(color: p.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < pages.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: i == _page ? 26 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page ? p.primary : p.border,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
              child: Column(
                children: [
                  PrimaryButton(
                    label: _page == pages.length - 1 ? l.getStarted : l.next,
                    onPressed: () {
                      if (_page == pages.length - 1) {
                        context.go('/register');
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 320),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: Text(
                      l.haveAccount,
                      style: TextStyle(
                        color: p.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
