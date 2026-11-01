import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_ext.dart';
import '../../../../core/theme/aman_palette.dart';
import '../../../../core/widgets/aman_card.dart';
import '../../../../core/widgets/misc_widgets.dart';
import '../../domain/clinic.dart';

/// Illustrated building cover derived from the clinic's seed.
class ClinicCover extends StatelessWidget {
  const ClinicCover({
    super.key,
    required this.clinic,
    this.height = 120,
    this.radius = 18,
  });

  final Clinic clinic;
  final double height;
  final double radius;

  static const _gradients = [
    [Color(0xFF4D9BFF), Color(0xFF0753C7)],
    [Color(0xFF3CC0B0), Color(0xFF0B7A8A)],
    [Color(0xFF7C8CFF), Color(0xFF3B47C7)],
    [Color(0xFF5BB5FF), Color(0xFF0866E9)],
  ];

  @override
  Widget build(BuildContext context) {
    final g = _gradients[clinic.imageSeed % _gradients.length];
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        height: height,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: g,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(right: -18, top: -18, child: _circle(90, 0.12)),
            Positioned(left: -24, bottom: -34, child: _circle(120, 0.10)),
            Center(
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double s, double a) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: a),
    ),
  );
}

class ClinicCard extends StatelessWidget {
  const ClinicCard({super.key, required this.clinic, required this.onTap});

  final Clinic clinic;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final t = Theme.of(context).textTheme;
    final l = context.l10n;
    return AmanCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      semanticLabel: clinic.name,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClinicCover(clinic: clinic, height: 96),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  clinic.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.titleSmall,
                ),
              ),
              RatingBadge(rating: clinic.rating),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 15,
                color: p.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(child: Text(clinic.fullAddress, style: t.bodySmall)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 15, color: p.textSecondary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  clinic.workingHours.of(context.langCode),
                  style: t.bodySmall,
                ),
              ),
            ],
          ),
          if (clinic.isDemo) ...[
            const SizedBox(height: 8),
            Text(l.verifiedDemoNote, style: t.labelSmall),
          ],
        ],
      ),
    );
  }
}
