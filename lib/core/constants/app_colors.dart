import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF212121); // Jet Black
  static const Color accent = Color(0xFF2962FF); // Electric Blue
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color border = Color(0xFFE0E0E0); // Grey-300

  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);

  // Deprecated/Legacy aliases to avoid breakage during refactor
  static const Color electricBlue = accent;
  static const Color grey300 = border;
  static const Color background = surface;
}
