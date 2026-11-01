import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/aman_palette.dart';
import '../theme/aman_spacing.dart';

/// Filled brand button with gradient, loading state and haptic feedback.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.expand = true,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final enabled = onPressed != null && !loading;
    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      child: loading
          ? const SizedBox(
              key: ValueKey('loading'),
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 20, color: Colors.white), const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1,
        child: Material(
          color: Colors.transparent,
          borderRadius: Corners.buttonRadius,
          child: Ink(
            height: height,
            width: expand ? double.infinity : null,
            decoration: BoxDecoration(
              borderRadius: Corners.buttonRadius,
              gradient: LinearGradient(
                colors: [p.secondary, p.primary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: enabled
                  ? [BoxShadow(color: p.primary.withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 8))]
                  : null,
            ),
            child: InkWell(
              borderRadius: Corners.buttonRadius,
              onTap: enabled
                  ? () {
                      HapticFeedback.selectionClick();
                      onPressed!();
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(widthFactor: expand ? null : 1, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined / tonal secondary button.
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    this.destructive = false,
    this.height = 54,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool destructive;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = destructive ? p.error : p.primary;
    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        height: height,
        width: expand ? double.infinity : null,
        child: OutlinedButton(
          onPressed: onPressed == null
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onPressed!();
                },
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            backgroundColor: destructive ? Colors.transparent : p.lightBlue,
            side: BorderSide(color: destructive ? p.error.withValues(alpha: 0.5) : Colors.transparent),
            shape: RoundedRectangleBorder(borderRadius: Corners.buttonRadius),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
              Flexible(
                child: Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Round icon button on a surface chip (used in app bars and cards).
class AmanIconButton extends StatelessWidget {
  const AmanIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.color,
    this.badge = 0,
    this.size = 44,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final Color? color;
  final int badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: p.surface,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox(
              width: size,
              height: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(icon, size: 22, color: color ?? p.textPrimary),
                  if (badge > 0)
                    Positioned(
                      top: 8,
                      right: 9,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: p.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: p.surface, width: 1.6),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
