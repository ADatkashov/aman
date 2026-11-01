import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../../core/widgets/aman_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final curve = CurvedAnimation(parent: _c, curve: Curves.easeOutBack);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [p.secondary, p.primary, p.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: CurvedAnimation(parent: _c, curve: const Interval(0, 0.6)),
            child: ScaleTransition(
              scale: Tween(begin: 0.7, end: 1.0).animate(curve),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const AmanLogoMark(size: 112, monochrome: true),
                  const SizedBox(height: 20),
                  const Text('AMAN',
                      style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  Text(context.l10n.tagline,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 15)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
