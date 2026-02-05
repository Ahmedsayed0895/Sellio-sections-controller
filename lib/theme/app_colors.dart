import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF530827);
  static const Color secondary = Color(0xFF880E4F);
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFFCE4EC);

  // Text Colors
  static const Color onPrimary = Colors.white;
  static const Color onSurface = Color(
    0xFF2D0415,
  ); // Very dark burgundy for text
  static const Color hint = Color(0xFF9E9E9E);

  // Status Colors
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF388E3C);

  // Constants
  static const double activeTrackOpacity = 0.2;
  static const double subtitleOpacity = 0.6;
  static const double avatarBgOpacity = 0.1;

  // Derived Getters
  static Color get activeTrack => primary.withValues(alpha: activeTrackOpacity);

  static Color get subtitle => onSurface.withValues(alpha: subtitleOpacity);

  static Color get avatarBg => primary.withValues(alpha: avatarBgOpacity);
}
