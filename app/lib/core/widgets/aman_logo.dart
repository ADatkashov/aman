import 'package:flutter/material.dart';

import '../theme/aman_palette.dart';

/// AMAN brand mark: a shield (safety) holding a medical cross whose
/// horizontal bar is a heartbeat line (health, life).
class AmanLogoMark extends StatelessWidget {
  const AmanLogoMark({super.key, this.size = 56, this.monochrome = false});

  final double size;

  /// White-on-transparent variant for use on blue backgrounds.
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'AMAN',
      child: CustomPaint(
        size: Size.square(size),
        painter: _LogoPainter(monochrome: monochrome),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  _LogoPainter({required this.monochrome});
  final bool monochrome;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final shield = Path()
      ..moveTo(w * 0.5, h * 0.03)
      ..cubicTo(w * 0.68, h * 0.14, w * 0.84, h * 0.17, w * 0.93, h * 0.17)
      ..lineTo(w * 0.93, h * 0.52)
      ..cubicTo(w * 0.93, h * 0.76, w * 0.74, h * 0.90, w * 0.5, h * 0.98)
      ..cubicTo(w * 0.26, h * 0.90, w * 0.07, h * 0.76, w * 0.07, h * 0.52)
      ..lineTo(w * 0.07, h * 0.17)
      ..cubicTo(w * 0.16, h * 0.17, w * 0.32, h * 0.14, w * 0.5, h * 0.03)
      ..close();

    final fill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: monochrome
            ? [Colors.white.withValues(alpha: 0.22), Colors.white.withValues(alpha: 0.12)]
            : [AmanPalette.light.secondary, AmanPalette.light.primary, AmanPalette.light.primaryDark],
      ).createShader(Offset.zero & size);
    canvas.drawPath(shield, fill);
    if (monochrome) {
      canvas.drawPath(
        shield,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = w * 0.035
          ..color = Colors.white,
      );
    }

    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = w * 0.085;

    // Vertical bar of the cross.
    canvas.drawLine(Offset(w * 0.5, h * 0.26), Offset(w * 0.5, h * 0.72), stroke);

    // Horizontal bar drawn as a heartbeat line.
    final pulse = Path()
      ..moveTo(w * 0.22, h * 0.50)
      ..lineTo(w * 0.38, h * 0.50)
      ..lineTo(w * 0.44, h * 0.38)
      ..lineTo(w * 0.52, h * 0.62)
      ..lineTo(w * 0.58, h * 0.50)
      ..lineTo(w * 0.78, h * 0.50);
    canvas.drawPath(pulse, stroke..strokeWidth = w * 0.07);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter old) => old.monochrome != monochrome;
}

/// Logo mark + "AMAN" wordmark.
class AmanLogo extends StatelessWidget {
  const AmanLogo({super.key, this.size = 40, this.light = false, this.showWordmark = true});

  final double size;
  final bool light;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AmanLogoMark(size: size, monochrome: light),
        if (showWordmark) ...[
          SizedBox(width: size * 0.28),
          Text(
            'AMAN',
            style: TextStyle(
              fontSize: size * 0.6,
              fontWeight: FontWeight.w900,
              letterSpacing: size * 0.06,
              color: light ? Colors.white : p.primaryDark,
            ),
          ),
        ],
      ],
    );
  }
}
