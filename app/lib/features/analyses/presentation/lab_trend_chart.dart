import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/aman_palette.dart';
import '../application/lab_providers.dart';

/// Line chart of one indicator over time with the laboratory reference band.
class LabTrendChart extends StatelessWidget {
  const LabTrendChart({super.key, required this.points, this.refMin, this.refMax, this.height = 170});

  final List<LabTrendPoint> points;
  final double? refMin;
  final double? refMax;
  final double height;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final fmt = context.fmt;
    return Semantics(
      label: points.map((e) => '${fmt.shortDate(e.date)}: ${fmt.compact(e.value)}').join(', '),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TrendPainter(
            points: points,
            refMin: refMin,
            refMax: refMax,
            line: p.primary,
            band: p.success.withValues(alpha: 0.12),
            bad: p.error,
            grid: p.border,
            text: p.textSecondary,
            surface: p.surface,
            dateLabel: (d) => '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}',
            valueLabel: fmt.compact,
          ),
        ),
      ),
    );
  }
}

class _TrendPainter extends CustomPainter {
  _TrendPainter({
    required this.points,
    required this.refMin,
    required this.refMax,
    required this.line,
    required this.band,
    required this.bad,
    required this.grid,
    required this.text,
    required this.surface,
    required this.dateLabel,
    required this.valueLabel,
  });

  final List<LabTrendPoint> points;
  final double? refMin;
  final double? refMax;
  final Color line;
  final Color band;
  final Color bad;
  final Color grid;
  final Color text;
  final Color surface;
  final String Function(DateTime) dateLabel;
  final String Function(num) valueLabel;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const left = 8.0, right = 12.0, top = 16.0, bottom = 26.0;
    final chart = Rect.fromLTRB(left, top, size.width - right, size.height - bottom);

    var lo = points.map((e) => e.value).reduce((a, b) => a < b ? a : b);
    var hi = points.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    if (refMin != null) lo = lo < refMin! ? lo : refMin!;
    if (refMax != null) hi = hi > refMax! ? hi : refMax!;
    final pad = (hi - lo).abs() < 1e-9 ? (hi.abs() * 0.1 + 1) : (hi - lo) * 0.15;
    lo -= pad;
    hi += pad;

    double y(double v) => chart.bottom - (v - lo) / (hi - lo) * chart.height;
    double x(int i) => points.length == 1 ? chart.center.dx : chart.left + chart.width * i / (points.length - 1);

    // Reference band.
    final bandTop = refMax != null ? y(refMax!) : chart.top;
    final bandBottom = refMin != null ? y(refMin!) : chart.bottom;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTRB(chart.left, bandTop, chart.right, bandBottom), const Radius.circular(8)),
      Paint()..color = band,
    );

    // Grid lines.
    final gridPaint = Paint()..color = grid..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final gy = chart.top + chart.height * i / 3;
      canvas.drawLine(Offset(chart.left, gy), Offset(chart.right, gy), gridPaint);
    }

    // Line.
    final path = Path();
    for (var i = 0; i < points.length; i++) {
      final o = Offset(x(i), y(points[i].value));
      i == 0 ? path.moveTo(o.dx, o.dy) : path.lineTo(o.dx, o.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // Points and labels.
    for (var i = 0; i < points.length; i++) {
      final v = points[i].value;
      final out = (refMin != null && v < refMin!) || (refMax != null && v > refMax!);
      final o = Offset(x(i), y(v));
      canvas.drawCircle(o, 7, Paint()..color = surface);
      canvas.drawCircle(o, 5, Paint()..color = out ? bad : line);
      _text(canvas, valueLabel(v), Offset(o.dx, o.dy - 20), out ? bad : text, bold: true);
      _text(canvas, dateLabel(points[i].date), Offset(o.dx, chart.bottom + 12), text);
    }
  }

  void _text(Canvas canvas, String s, Offset center, Color color, {bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: TextStyle(fontSize: 11, color: color, fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _TrendPainter old) =>
      old.points != points || old.refMin != refMin || old.refMax != refMax || old.line != line;
}
