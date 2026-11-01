import 'package:flutter/material.dart';

import '../theme/aman_palette.dart';
import '../theme/aman_spacing.dart';

/// White rounded surface with a soft shadow; tappable when [onTap] is set.
class AmanCard extends StatelessWidget {
  const AmanCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.color,
    this.radius,
    this.border = false,
    this.shadow = true,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double? radius;
  final bool border;
  final bool shadow;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final br = BorderRadius.circular(radius ?? Corners.card);
    final dark = Theme.of(context).brightness == Brightness.dark;
    final content = Ink(
      decoration: BoxDecoration(
        color: color ?? p.surface,
        borderRadius: br,
        border: border || dark ? Border.all(color: p.border) : null,
        boxShadow: shadow && !dark
            ? [
                BoxShadow(
                  color: const Color(0xFF0A2A66).withValues(alpha: 0.06),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Padding(padding: padding, child: child),
    );
    final tappable = onTap == null
        ? content
        : InkWell(borderRadius: br, onTap: onTap, child: content);
    return Semantics(
      container: true,
      button: onTap != null,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        borderRadius: br,
        child: tappable,
      ),
    );
  }
}
