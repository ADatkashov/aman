import 'package:flutter/material.dart';

/// AMAN design tokens. Light values come from the brand specification;
/// dark values are tuned for contrast on OLED screens.
@immutable
class AmanPalette extends ThemeExtension<AmanPalette> {
  const AmanPalette({
    required this.primary,
    required this.primaryDark,
    required this.secondary,
    required this.lightBlue,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.success,
    required this.warning,
    required this.error,
    required this.border,
  });

  final Color primary;
  final Color primaryDark;
  final Color secondary;
  final Color lightBlue;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color success;
  final Color warning;
  final Color error;
  final Color border;

  static const light = AmanPalette(
    primary: Color(0xFF0866E9),
    primaryDark: Color(0xFF0753C7),
    secondary: Color(0xFF4D9BFF),
    lightBlue: Color(0xFFEAF3FF),
    background: Color(0xFFF4F7FC),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF172B4D),
    textSecondary: Color(0xFF74839A),
    success: Color(0xFF16A36A),
    warning: Color(0xFFF5A623),
    error: Color(0xFFE5484D),
    border: Color(0xFFE8EDF5),
  );

  static const dark = AmanPalette(
    primary: Color(0xFF4D9BFF),
    primaryDark: Color(0xFF0866E9),
    secondary: Color(0xFF7DB5FF),
    lightBlue: Color(0xFF16263F),
    background: Color(0xFF0B1220),
    surface: Color(0xFF131C2E),
    textPrimary: Color(0xFFEAF0FA),
    textSecondary: Color(0xFF93A3BC),
    success: Color(0xFF34C48A),
    warning: Color(0xFFF7B84B),
    error: Color(0xFFFF6B70),
    border: Color(0xFF223049),
  );

  @override
  AmanPalette copyWith({
    Color? primary,
    Color? primaryDark,
    Color? secondary,
    Color? lightBlue,
    Color? background,
    Color? surface,
    Color? textPrimary,
    Color? textSecondary,
    Color? success,
    Color? warning,
    Color? error,
    Color? border,
  }) => AmanPalette(
    primary: primary ?? this.primary,
    primaryDark: primaryDark ?? this.primaryDark,
    secondary: secondary ?? this.secondary,
    lightBlue: lightBlue ?? this.lightBlue,
    background: background ?? this.background,
    surface: surface ?? this.surface,
    textPrimary: textPrimary ?? this.textPrimary,
    textSecondary: textSecondary ?? this.textSecondary,
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    border: border ?? this.border,
  );

  @override
  AmanPalette lerp(ThemeExtension<AmanPalette>? other, double t) {
    if (other is! AmanPalette) return this;
    return AmanPalette(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      lightBlue: Color.lerp(lightBlue, other.lightBlue, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

extension PaletteContext on BuildContext {
  AmanPalette get palette => Theme.of(this).extension<AmanPalette>()!;
}
