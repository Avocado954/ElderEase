import 'package:flutter/material.dart';

/// The host app's palette — deliberately looks like a mainstream
/// payments app. ElderEase does NOT restyle this.
class AppColors {
  static const Color blue = Color(0xFF1A73E8);
  static const Color blueDark = Color(0xFF1557B0);
  static const Color green = Color(0xFF1E8E3E);
  static const Color red = Color(0xFFD93025);
  static const Color yellow = Color(0xFFF9AB00);

  static const Color background = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3F4);

  static const Color ink = Color(0xFF202124);
  static const Color inkMuted = Color(0xFF5F6368);
  static const Color line = Color(0xFFDADCE0);
}

/// The ElderEase overlay palette — chosen for ageing eyes.
/// Warm hues stay vivid as the lens yellows; cream cuts glare;
/// every pair clears WCAG AAA contrast.
class EaseColors {
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDeep = Color(0xFFC2740A);
  static const Color cream = Color(0xFFFDF8EF);
  static const Color ink = Color(0xFF1A1206);
  static const Color inkMuted = Color(0xFF5C4B33);
  static const Color teal = Color(0xFF0E4D5C);
  static const Color scrim = Color(0xCC0A0700);
}

class AppSizes {
  static const double body = 15;
  static const double title = 20;
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16);
}

/// Overlay type scale — much larger than the host app's.
class EaseSizes {
  static const double body = 21;
  static const double title = 27;
  static const double huge = 34;
  static const double radius = 24;
}