import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1565C0); // Blue 800 - Deep Navy
  static const Color secondary = Color(0xFF42A5F5); // Blue 400 - Light Blue
  static const Color accent = secondary;

  // Background & Surface
  static const Color background = Color(0xFFF5F7FA); // Cool White/Greyish
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color neutral = Color(
    0xFFF0F4F8,
  ); // Very Light Blue/Grey (Block)
  static const Color border = Color(0xFFE0E0E0); // Grey 300

  // Text Colors
  static const Color textPrimary = Color(
    0xFF0D1B2A,
  ); // Dark Navy / Almost Black
  static const Color textSecondary = Color(0xFF616161); // Grey 700
  static const Color textTertiary = Color(0xFF9E9E9E); // Grey 500

  // Semantic Colors
  static const Color success = Color(0xFF00C853); // Green A700
  static const Color warning = Color(0xFFFFAB00); // Amber A700
  static const Color error = Color(0xFFD50000); // Red A700
}
