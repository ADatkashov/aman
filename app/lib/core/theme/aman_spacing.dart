import 'package:flutter/material.dart';

/// Spacing and radius scale (4-pt grid).
abstract final class Space {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double huge = 32;

  /// Horizontal page gutter.
  static const double gutter = 20;
}

abstract final class Corners {
  static const double chip = 12;
  static const double card = 20;
  static const double sheet = 28;
  static const double button = 16;

  static BorderRadius get cardRadius => BorderRadius.circular(card);
  static BorderRadius get buttonRadius => BorderRadius.circular(button);
  static BorderRadius get chipRadius => BorderRadius.circular(chip);
}
