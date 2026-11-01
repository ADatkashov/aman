import 'package:flutter/material.dart';

import '../l10n/l10n_ext.dart';
import '../theme/aman_palette.dart';
import 'buttons.dart';

enum BadgeTone { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    this.tone = BadgeTone.info,
    this.icon,
  });

  final String label;
  final BadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = switch (tone) {
      BadgeTone.success => p.success,
      BadgeTone.warning => p.warning,
      BadgeTone.error => p.error,
      BadgeTone.info => p.primary,
      BadgeTone.neutral => p.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RatingBadge extends StatelessWidget {
  const RatingBadge({super.key, required this.rating, this.reviews});

  final double rating;
  final int? reviews;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fmt = context.fmt;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: 17, color: p.warning),
        const SizedBox(width: 3),
        Text(
          fmt.decimal(rating),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        if (reviews != null) ...[
          const SizedBox(width: 4),
          Text('(${reviews!})', style: Theme.of(context).textTheme.bodySmall),
        ],
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.titleLarge),
          ),
          if (onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel ?? context.l10n.seeAll,
                style: TextStyle(color: p.primary, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    );
  }
}

/// Small label + value pair used on detail screens.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: p.lightBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: p.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: t.bodySmall),
                  const SizedBox(height: 2),
                  Text(value, style: t.titleSmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// DEMO tag shown next to synthetic content.
class DemoTag extends StatelessWidget {
  const DemoTag({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: p.warning.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.demoBadge,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: p.warning,
        ),
      ),
    );
  }
}

/// Confirmation dialog for critical actions. Returns `true` when confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) async {
  final p = context.palette;
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(cancelLabel ?? ctx.l10n.cancel),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: destructive ? p.error : p.primary,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

void showSnack(BuildContext context, String message, {bool error = false}) {
  final p = context.palette;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              error ? Icons.error_outline_rounded : Icons.check_circle_rounded,
              color: error ? p.error : p.success,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
}

/// Bottom call-to-action bar used on detail / wizard screens.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        12 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(top: BorderSide(color: p.border)),
      ),
      child: child,
    );
  }
}

/// Convenience: primary button with a trailing arrow.
class ContinueButton extends StatelessWidget {
  const ContinueButton({
    super.key,
    required this.onPressed,
    this.label,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String? label;
  final bool loading;

  @override
  Widget build(BuildContext context) => PrimaryButton(
    label: label ?? context.l10n.continueAction,
    onPressed: onPressed,
    loading: loading,
  );
}
