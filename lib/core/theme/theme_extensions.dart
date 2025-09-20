import 'package:cutout_ai/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

// Extensions pour des couleurs personnalisées
extension AppColors on ColorScheme {
  Color get success => brightness == Brightness.light
      ? AppTheme.successColor
      : const Color(0xFF86EFAC);

  Color get warning => brightness == Brightness.light
      ? AppTheme.warningColor
      : const Color(0xFFFBBF24);

  Color get cardShadow => brightness == Brightness.light
      ? Colors.black.withValues(alpha: 0.1)
      : Colors.transparent;
}

// Extensions pour les styles de texte
extension AppTextStyles on TextTheme {
  TextStyle get heading1 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.5,
  );

  TextStyle get heading2 => const TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.25,
  );

  TextStyle get subtitle => const TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  TextStyle get body => const TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  TextStyle get caption => const TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );
}
