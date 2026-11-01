import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';

import 'aman_palette.dart';
import 'aman_spacing.dart';

/// Builds the Material 3 themes customised with the AMAN design system.
abstract final class AppTheme {
  static ThemeData get light => _build(AmanPalette.light, Brightness.light);
  static ThemeData get dark => _build(AmanPalette.dark, Brightness.dark);

  static ThemeData _build(AmanPalette p, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: AmanPalette.light.primary,
      brightness: brightness,
    ).copyWith(
      primary: p.primary,
      onPrimary: brightness == Brightness.light ? Colors.white : const Color(0xFF06142B),
      secondary: p.secondary,
      surface: p.surface,
      onSurface: p.textPrimary,
      error: p.error,
      outline: p.border,
      surfaceContainerHighest: p.lightBlue,
    );

    final text = _textTheme(p);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: p.background,
      textTheme: text,
      extensions: [p],
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: p.background,
        foregroundColor: p.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.titleMedium,
      ),
      cardTheme: CardThemeData(
        color: p.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: Corners.cardRadius),
      ),
      dividerTheme: DividerThemeData(color: p.border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: p.textSecondary),
        border: _inputBorder(p.border),
        enabledBorder: _inputBorder(p.border),
        focusedBorder: _inputBorder(p.primary, width: 1.6),
        errorBorder: _inputBorder(p.error),
        focusedErrorBorder: _inputBorder(p.error, width: 1.6),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: p.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(color: p.surface),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Corners.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
      }),
    );
  }

  static OutlineInputBorder _inputBorder(Color c, {double width = 1}) =>
      OutlineInputBorder(
        borderRadius: Corners.buttonRadius,
        borderSide: BorderSide(color: c, width: width),
      );

  static TextTheme _textTheme(AmanPalette p) {
    TextStyle s(double size, FontWeight w, {Color? c, double? h, double? ls}) =>
        TextStyle(
          fontSize: size,
          fontWeight: w,
          color: c ?? p.textPrimary,
          height: h,
          letterSpacing: ls,
        );
    return TextTheme(
      displaySmall: s(32, FontWeight.w800, h: 1.15, ls: -0.8),
      headlineMedium: s(26, FontWeight.w800, h: 1.2, ls: -0.5),
      headlineSmall: s(22, FontWeight.w700, h: 1.25, ls: -0.3),
      titleLarge: s(19, FontWeight.w700, h: 1.3),
      titleMedium: s(16, FontWeight.w700, h: 1.3),
      titleSmall: s(14, FontWeight.w600, h: 1.3),
      bodyLarge: s(16, FontWeight.w400, h: 1.45),
      bodyMedium: s(14, FontWeight.w400, h: 1.45),
      bodySmall: s(12, FontWeight.w400, c: p.textSecondary, h: 1.4),
      labelLarge: s(15, FontWeight.w700),
      labelMedium: s(13, FontWeight.w600),
      labelSmall: s(11, FontWeight.w600, c: p.textSecondary),
    );
  }
}
