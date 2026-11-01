import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../../catalog/domain/clinic.dart';

/// Map integration point.
///
/// A production adapter (Google Maps / 2GIS MapGL) implements this interface
/// and is registered through [mapAdapterProvider]; those SDKs require native
/// API keys. Without keys the [DemoMapAdapter] renders an interactive
/// schematic map so that every button keeps working.
abstract class MapAdapter {
  const MapAdapter();

  /// Whether this adapter shows live map tiles.
  bool get isLive;

  Widget build({
    required BuildContext context,
    required List<Clinic> clinics,
    required String? selectedId,
    required ValueChanged<Clinic> onSelect,
  });
}

final mapAdapterProvider = Provider<MapAdapter>(
  (ref) => const DemoMapAdapter(),
);

class DemoMapAdapter extends MapAdapter {
  const DemoMapAdapter();

  @override
  bool get isLive => false;

  @override
  Widget build({
    required BuildContext context,
    required List<Clinic> clinics,
    required String? selectedId,
    required ValueChanged<Clinic> onSelect,
  }) =>
      DemoMapView(clinics: clinics, selectedId: selectedId, onSelect: onSelect);
}

class DemoMapView extends StatelessWidget {
  const DemoMapView({
    super.key,
    required this.clinics,
    required this.selectedId,
    required this.onSelect,
  });

  final List<Clinic> clinics;
  final String? selectedId;
  final ValueChanged<Clinic> onSelect;

  /// Projects clinics into the unit square, fitted to their bounding box.
  static Map<String, Offset> project(List<Clinic> clinics) {
    if (clinics.isEmpty) return const {};
    var minLat = clinics.first.latitude, maxLat = minLat;
    var minLng = clinics.first.longitude, maxLng = minLng;
    for (final c in clinics) {
      minLat = math.min(minLat, c.latitude);
      maxLat = math.max(maxLat, c.latitude);
      minLng = math.min(minLng, c.longitude);
      maxLng = math.max(maxLng, c.longitude);
    }
    final dLat = math.max(maxLat - minLat, 0.01);
    final dLng = math.max(maxLng - minLng, 0.01);
    return {
      for (final c in clinics)
        c.id: Offset(
          0.14 + 0.72 * (c.longitude - minLng) / dLng,
          0.14 + 0.72 * (1 - (c.latitude - minLat) / dLat),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final points = project(clinics);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: InteractiveViewer(
        minScale: 1,
        maxScale: 3.5,
        child: LayoutBuilder(
          builder: (_, c) => SizedBox(
            width: c.maxWidth,
            height: c.maxHeight,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _MapPainter(
                      land: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF16233A)
                          : const Color(0xFFE9F1FB),
                      road: p.surface,
                      park: p.success.withValues(alpha: 0.14),
                      water: p.secondary.withValues(alpha: 0.18),
                    ),
                  ),
                ),
                for (final clinic in clinics)
                  if (points[clinic.id] != null)
                    Positioned(
                      left: points[clinic.id]!.dx * c.maxWidth - 24,
                      top: points[clinic.id]!.dy * c.maxHeight - 52,
                      child: _Marker(
                        clinic: clinic,
                        selected: clinic.id == selectedId,
                        onTap: () => onSelect(clinic),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.clinic,
    required this.selected,
    required this.onTap,
  });

  final Clinic clinic;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: clinic.name,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: SizedBox(
          width: 48,
          height: 56,
          child: AnimatedScale(
            scale: selected ? 1.2 : 1,
            duration: const Duration(milliseconds: 180),
            alignment: Alignment.bottomCenter,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: selected ? p.primary : p.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: p.primary, width: 2.4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_rounded,
                    color: selected ? Colors.white : p.primary,
                    size: 26,
                  ),
                ),
                CustomPaint(
                  size: const Size(14, 10),
                  painter: _PinTail(
                    selected ? p.primary : p.surface,
                    p.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PinTail extends CustomPainter {
  _PinTail(this.fill, this.stroke);
  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size s) {
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width / 2, s.height)
      ..close();
    canvas.drawPath(path, Paint()..color = fill);
    canvas.drawPath(
      path,
      Paint()
        ..color = stroke
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant _PinTail old) => old.fill != fill;
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.land,
    required this.road,
    required this.park,
    required this.water,
  });
  final Color land;
  final Color road;
  final Color park;
  final Color water;

  @override
  void paint(Canvas canvas, Size s) {
    canvas.drawRect(Offset.zero & s, Paint()..color = land);
    // Park and river shapes.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.08,
          s.height * 0.62,
          s.width * 0.26,
          s.height * 0.22,
        ),
        const Radius.circular(24),
      ),
      Paint()..color = park,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          s.width * 0.62,
          s.height * 0.1,
          s.width * 0.28,
          s.height * 0.16,
        ),
        const Radius.circular(24),
      ),
      Paint()..color = park,
    );
    final river = Path()
      ..moveTo(0, s.height * 0.42)
      ..cubicTo(
        s.width * 0.3,
        s.height * 0.3,
        s.width * 0.55,
        s.height * 0.6,
        s.width,
        s.height * 0.46,
      );
    canvas.drawPath(
      river,
      Paint()
        ..color = water
        ..style = PaintingStyle.stroke
        ..strokeWidth = s.height * 0.045
        ..strokeCap = StrokeCap.round,
    );

    final major = Paint()
      ..color = road
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    final minor = Paint()
      ..color = road
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i < 6; i++) {
      final x = s.width * i / 6;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + (i.isEven ? 14 : -10), s.height),
        i % 3 == 0 ? major : minor,
      );
    }
    for (var j = 1; j < 8; j++) {
      final y = s.height * j / 8;
      canvas.drawLine(
        Offset(0, y),
        Offset(s.width, y + (j.isOdd ? 10 : -12)),
        j % 3 == 0 ? major : minor,
      );
    }
    canvas.drawLine(Offset(0, s.height), Offset(s.width, 0), major);
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.land != land || old.road != road;
}

/// Small helper reused by tests: label under the map when running in demo mode.
String mapNote(BuildContext context, MapAdapter adapter) =>
    adapter.isLive ? '' : context.l10n.mapDemoNote;
