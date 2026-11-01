import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_ext.dart';
import '../../core/widgets/app_bars.dart';

/// Scaffold with the persistent four-tab bottom navigation.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: shell,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: shell.currentIndex,
        onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          NavDestinationData(Icons.home_outlined, Icons.home_rounded, l.navHome),
          NavDestinationData(Icons.calendar_month_outlined, Icons.calendar_month_rounded, l.navAppointments),
          NavDestinationData(Icons.grid_view_outlined, Icons.grid_view_rounded, l.navServices),
          NavDestinationData(Icons.person_outline_rounded, Icons.person_rounded, l.navProfile),
        ],
      ),
    );
  }
}
