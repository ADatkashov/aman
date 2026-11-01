import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/utils/phone.dart';
import '../../../core/widgets/aman_card.dart';
import '../../../core/widgets/app_bars.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/doctor_avatar.dart';
import '../../../core/widgets/misc_widgets.dart';
import '../../analyses/application/lab_providers.dart';
import '../../appointments/application/appointments_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../documents/application/documents_controller.dart';
import '../../notifications/application/notifications_controller.dart';
import '../../settings/application/settings_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final fmt = context.fmt;
    final profile = ref.watch(authControllerProvider).value;
    final appts = ref.watch(appointmentsProvider).value?.length;
    final labs = ref.watch(labResultsProvider).value?.length;
    final docs = ref.watch(documentsProvider).value?.length;
    final favs = ref.watch(favoritesProvider).value?.length;
    final unread = ref.watch(unreadCountProvider);
    final locale = ref.watch(localeProvider);
    const langNames = {'kk': 'Қазақша', 'ru': 'Русский', 'en': 'English'};

    if (profile == null) return const SizedBox.shrink();
    final age = profile.ageAt(DateTime.now());

    Widget menu(IconData icon, String title, VoidCallback onTap, {String? trailing, int badge = 0, Color? color}) =>
        ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: (color ?? p.primary).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color ?? p.primary, size: 21),
          ),
          title: Text(title, style: t.titleSmall),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
            if (trailing != null) Text(trailing, style: t.bodySmall),
            if (badge > 0)
              Container(
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: p.error, borderRadius: BorderRadius.circular(10)),
                child: Text('$badge', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            Icon(Icons.chevron_right_rounded, color: p.textSecondary),
          ]),
        );

    return Scaffold(
      appBar: CustomAppBar(title: l.profileTitle, showBack: false),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        children: [
          AmanCard(
            child: Column(
              children: [
                Row(
                  children: [
                    InitialsAvatar(name: profile.fullName, size: 68),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile.fullName, style: t.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            [
                              profile.gender.name == 'male' ? l.male : l.female,
                              if (age != null) l.recAgeValue(age),
                            ].join(', '),
                            style: t.bodySmall,
                          ),
                          Text(KzPhone.format(profile.phone), style: t.bodySmall),
                          if (profile.email != null) Text(profile.email!, style: t.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (profile.birthDate != null)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('${l.birthDateLabel}: ${fmt.dayMonthYear(profile.birthDate!)}', style: t.bodySmall),
                  ),
                const SizedBox(height: 12),
                SecondaryButton(label: l.editProfile, icon: Icons.edit_rounded, height: 46, onPressed: () => context.push('/profile/edit')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(label: l.statAppointments, value: appts, onTap: () => context.go('/appointments')),
              const SizedBox(width: 10),
              _Stat(label: l.statAnalyses, value: labs, onTap: () => context.push('/analyses')),
              const SizedBox(width: 10),
              _Stat(label: l.statDocuments, value: docs, onTap: () => context.push('/documents')),
              const SizedBox(width: 10),
              _Stat(label: l.statFavorites, value: favs, onTap: () => context.push('/favorites')),
            ],
          ),
          const SizedBox(height: 14),
          AmanCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                menu(Icons.person_rounded, l.personalData, () => context.push('/profile/edit')),
                menu(Icons.history_rounded, l.appointmentHistory, () => context.go('/appointments')),
                menu(Icons.folder_shared_rounded, l.medicalRecordMenu, () => context.push('/medical-record')),
                menu(Icons.science_rounded, l.myAnalyses, () => context.push('/analyses')),
                menu(Icons.description_rounded, l.myDocuments, () => context.push('/documents')),
                menu(Icons.favorite_rounded, l.favoriteDoctors, () => context.push('/favorites')),
                menu(Icons.notifications_rounded, l.notificationsMenu, () => context.push('/notifications'), badge: unread),
              ],
            ),
          ),
          const SizedBox(height: 14),
          AmanCard(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                menu(Icons.settings_rounded, l.settingsMenu, () => context.push('/settings')),
                menu(Icons.language_rounded, l.languageMenu, () => context.push('/settings'), trailing: langNames[locale.languageCode]),
                menu(Icons.lock_rounded, l.securityMenu, () => context.push('/security')),
                menu(Icons.help_rounded, l.helpMenu, () => context.push('/help')),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SecondaryButton(
            label: l.logout,
            icon: Icons.logout_rounded,
            destructive: true,
            onPressed: () async {
              final ok = await confirmAction(
                context,
                title: l.logoutConfirmTitle,
                body: l.logoutConfirmBody,
                confirmLabel: l.logout,
                destructive: true,
              );
              if (ok) await ref.read(authControllerProvider.notifier).logout();
            },
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, required this.onTap});
  final String label;
  final int? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final p = context.palette;
    return Expanded(
      child: AmanCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Column(
          children: [
            Text(value?.toString() ?? '–', style: t.titleLarge?.copyWith(color: p.primary)),
            const SizedBox(height: 2),
            FittedBox(fit: BoxFit.scaleDown, child: Text(label, style: t.bodySmall)),
          ],
        ),
      ),
    );
  }
}
