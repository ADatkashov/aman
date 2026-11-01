import 'package:flutter/material.dart';

import '../theme/aman_palette.dart';

/// Professional-looking illustrated portrait derived from a seed.
///
/// The app ships no real photographs of people. If [photoUrl] is available it
/// is shown; otherwise a deterministic illustration (white coat, stethoscope)
/// is painted so that every doctor still gets a distinct, friendly avatar.
class DoctorAvatar extends StatelessWidget {
  const DoctorAvatar({
    super.key,
    required this.seed,
    this.size = 64,
    this.female = false,
    this.photoUrl,
    this.radius,
  });

  final int seed;
  final double size;
  final bool female;
  final String? photoUrl;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius ?? size * 0.28);
    final painted = CustomPaint(
      size: Size.square(size),
      painter: _AvatarPainter(seed: seed, female: female),
    );
    return ClipRRect(
      borderRadius: r,
      child: SizedBox(
        width: size,
        height: size,
        child: photoUrl == null
            ? painted
            : Image.network(photoUrl!, fit: BoxFit.cover, errorBuilder: (_, _, _) => painted),
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  _AvatarPainter({required this.seed, required this.female});
  final int seed;
  final bool female;

  static const _skin = [Color(0xFFF3D2B6), Color(0xFFE8B98F), Color(0xFFD9A074), Color(0xFFF7DCC5)];
  static const _hair = [Color(0xFF2B2118), Color(0xFF4A3426), Color(0xFF1B1B1F), Color(0xFF6B4A2F), Color(0xFF8A6A45)];
  static const _bg = [
    [Color(0xFFD7E9FF), Color(0xFFB5D5FF)],
    [Color(0xFFDDF3F0), Color(0xFFB8E4DE)],
    [Color(0xFFE6E4FF), Color(0xFFCFCBFF)],
    [Color(0xFFE2EEFF), Color(0xFFC4DBFF)],
  ];

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final h = s.height;
    final skin = _skin[seed % _skin.length];
    final hair = _hair[(seed * 3) % _hair.length];
    final bg = _bg[seed % _bg.length];

    canvas.drawRect(
      Offset.zero & s,
      Paint()
        ..shader = LinearGradient(colors: bg, begin: Alignment.topCenter, end: Alignment.bottomCenter)
            .createShader(Offset.zero & s),
    );

    // Long hair behind the head (female variant).
    if (female) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(w * 0.5, h * 0.44), width: w * 0.52, height: h * 0.52),
          Radius.circular(w * 0.22),
        ),
        Paint()..color = hair,
      );
    }

    // Shoulders / white coat.
    final coat = Path()
      ..moveTo(w * 0.06, h)
      ..cubicTo(w * 0.06, h * 0.74, w * 0.26, h * 0.66, w * 0.5, h * 0.66)
      ..cubicTo(w * 0.74, h * 0.66, w * 0.94, h * 0.74, w * 0.94, h)
      ..close();
    canvas.drawPath(coat, Paint()..color = Colors.white);
    canvas.drawPath(
      coat,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFD5E1F2)
        ..strokeWidth = w * 0.012,
    );

    // Scrubs V-neck.
    final scrubs = Path()
      ..moveTo(w * 0.40, h * 0.67)
      ..lineTo(w * 0.5, h * 0.82)
      ..lineTo(w * 0.60, h * 0.67)
      ..close();
    canvas.drawPath(scrubs, Paint()..color = AmanPalette.light.secondary);

    // Neck.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(w * 0.5, h * 0.62), width: w * 0.16, height: h * 0.12),
        Radius.circular(w * 0.05),
      ),
      Paint()..color = skin.withValues(alpha: 0.92),
    );

    // Head.
    final headCenter = Offset(w * 0.5, h * 0.42);
    canvas.drawOval(
      Rect.fromCenter(center: headCenter, width: w * 0.36, height: h * 0.42),
      Paint()..color = skin,
    );

    // Hair cap.
    final cap = Path()
      ..addArc(
        Rect.fromCenter(center: headCenter.translate(0, -h * 0.04), width: w * 0.40, height: h * 0.40),
        3.1416,
        3.1416,
      );
    canvas.drawPath(cap, Paint()..color = hair);
    if (!female) {
      canvas.drawRect(
        Rect.fromLTWH(w * 0.30, h * 0.30, w * 0.40, h * 0.035),
        Paint()..color = hair,
      );
    }

    // Eyes + smile.
    final face = Paint()..color = const Color(0xFF3A2A22);
    canvas.drawCircle(Offset(w * 0.43, h * 0.44), w * 0.014, face);
    canvas.drawCircle(Offset(w * 0.57, h * 0.44), w * 0.014, face);
    canvas.drawArc(
      Rect.fromCenter(center: Offset(w * 0.5, h * 0.50), width: w * 0.12, height: h * 0.07),
      0.2,
      2.7,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFB8665A)
        ..strokeWidth = w * 0.012
        ..strokeCap = StrokeCap.round,
    );

    // Stethoscope.
    final steth = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF516079)
      ..strokeWidth = w * 0.018
      ..strokeCap = StrokeCap.round;
    final tube = Path()
      ..moveTo(w * 0.36, h * 0.70)
      ..cubicTo(w * 0.30, h * 0.92, w * 0.62, h * 0.96, w * 0.64, h * 0.78);
    canvas.drawPath(tube, steth);
    canvas.drawCircle(Offset(w * 0.64, h * 0.80), w * 0.03, Paint()..color = const Color(0xFF516079));
  }

  @override
  bool shouldRepaint(covariant _AvatarPainter old) => old.seed != seed || old.female != female;
}

/// Illustrated avatar for patients (initials on a brand gradient).
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 56});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((s) => s.isEmpty ? '' : s[0].toUpperCase()).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [p.secondary, p.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Text(
        initials,
        style: TextStyle(color: Colors.white, fontSize: size * 0.36, fontWeight: FontWeight.w800),
      ),
    );
  }
}
