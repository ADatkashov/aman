// Renders the AMAN logo to PNG files used by flutter_launcher_icons.
//
//   flutter test tool/generate_icon.dart
//
// Output: assets/icon/aman_icon.png (full icon), assets/icon/aman_icon_fg.png (adaptive foreground).
import 'dart:io';
import 'dart:ui' as ui;

import 'package:aman/core/widgets/aman_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _render(WidgetTester tester, String path, {required Color? background, required double logoScale}) async {
  const size = 1024.0;
  final key = GlobalKey();
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: key,
          child: Container(
            width: size,
            height: size,
            decoration: background == null
                ? null
                : BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D9BFF), Color(0xFF0753C7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
            alignment: Alignment.center,
            child: AmanLogoMark(size: size * logoScale, monochrome: background != null),
          ),
        ),
      ),
    ),
  );
  await tester.runAsync(() async {
    final boundary = key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await boundary.toImage();
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    File(path).writeAsBytesSync(data!.buffer.asUint8List());
  });
}

void main() {
  testWidgets('generate launcher icons', (tester) async {
    tester.view.physicalSize = const Size(1200, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await _render(tester, 'assets/icon/aman_icon.png', background: const Color(0xFF0866E9), logoScale: 0.66);
    await _render(tester, 'assets/icon/aman_icon_fg.png', background: null, logoScale: 0.5);
  });
}
