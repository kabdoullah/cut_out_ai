import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand palette
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color primaryVioletLight = Color(0xFF8B5CF6);
  static const Color accentFuchsia = Color(0xFFD946EF);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF22C55E);

  // Brand gradient — violet → fuchsia
  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryViolet, accentFuchsia],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradientSubtle = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Light surface tokens
  static const Color _lightBg = Color(0xFFFAF9FF);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFF3F0FF);
  static const Color _lightText = Color(0xFF09090B);
  static const Color _lightSubtext = Color(0xFF71717A);
  static const Color _lightOutline = Color(0xFFE4E4E7);

  // Dark surface tokens
  static const Color _darkBg = Color(0xFF09090B);
  static const Color _darkSurface = Color(0xFF18181B);
  static const Color _darkCard = Color(0xFF27272A);
  static const Color _darkText = Color(0xFFFAFAFA);
  static const Color _darkSubtext = Color(0xFFA1A1AA);
  static const Color _darkOutline = Color(0xFF3F3F46);

  static TextTheme _textTheme(Color color) {
    final outfit = GoogleFonts.outfit(color: color);
    return TextTheme(
      displayLarge: GoogleFonts.outfit(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        color: color,
      ),
      displayMedium: GoogleFonts.outfit(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: color,
      ),
      displaySmall: GoogleFonts.outfit(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: color,
      ),
      headlineLarge: GoogleFonts.outfit(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      headlineMedium: GoogleFonts.outfit(
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      ),
      headlineSmall: GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      ),
      titleLarge: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: color,
      ),
      titleMedium: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      ),
      bodyLarge: GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelLarge: GoogleFonts.outfit(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      ),
      labelMedium: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: color,
      ),
      labelSmall: GoogleFonts.outfit(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: color,
      ),
    ).apply(
      bodyColor: color,
      displayColor: color,
      decorationColor: outfit.color,
    );
  }

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    textTheme: _textTheme(_lightText),
    colorScheme: const ColorScheme.light(
      primary: primaryViolet,
      primaryContainer: Color(0xFFEDE9FE),
      secondary: accentFuchsia,
      secondaryContainer: Color(0xFFFCE7FF),
      tertiary: accentCyan,
      tertiaryContainer: Color(0xFFCFFAFE),
      surface: _lightSurface,
      surfaceContainerHighest: _lightCard,
      surfaceContainerHigh: Color(0xFFF5F3FF),
      surfaceContainer: Color(0xFFF8F7FF),
      error: errorRed,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: Colors.white,
      onSurface: _lightText,
      onSurfaceVariant: _lightSubtext,
      outline: _lightOutline,
      outlineVariant: Color(0xFFF4F4F5),
      shadow: Color(0x1A09090B),
      scrim: Color(0x8009090B),
    ),
    scaffoldBackgroundColor: _lightBg,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: _lightBg,
      foregroundColor: _lightText,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _lightText,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: _lightOutline),
      ),
      color: _lightSurface,
      shadowColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _lightOutline),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _lightCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryViolet, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _lightOutline,
      space: 1,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: _lightText, size: 24),
    chipTheme: ChipThemeData(
      backgroundColor: _lightCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: _lightOutline),
      labelStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _lightText,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: GoogleFonts.nunito(fontSize: 14),
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: _lightSurface,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryViolet,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    textTheme: _textTheme(_darkText),
    colorScheme: const ColorScheme.dark(
      primary: primaryVioletLight,
      primaryContainer: Color(0xFF4C1D95),
      secondary: accentFuchsia,
      secondaryContainer: Color(0xFF701A75),
      tertiary: accentCyan,
      tertiaryContainer: Color(0xFF164E63),
      surface: _darkSurface,
      surfaceContainerHighest: _darkCard,
      surfaceContainerHigh: Color(0xFF1C1C1F),
      surfaceContainer: Color(0xFF141417),
      error: Color(0xFFFCA5A5),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onTertiary: _darkBg,
      onSurface: _darkText,
      onSurfaceVariant: _darkSubtext,
      outline: _darkOutline,
      outlineVariant: Color(0xFF29292D),
      shadow: Color(0x33000000),
      scrim: Color(0xB3000000),
    ),
    scaffoldBackgroundColor: _darkBg,
    appBarTheme: AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      backgroundColor: _darkBg,
      foregroundColor: _darkText,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: _darkText,
        letterSpacing: -0.2,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        side: BorderSide(color: _darkOutline),
      ),
      color: _darkSurface,
      shadowColor: Colors.transparent,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: const BorderSide(color: _darkOutline),
        textStyle: GoogleFonts.outfit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkOutline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryVioletLight, width: 2),
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: _darkOutline,
      space: 1,
      thickness: 1,
    ),
    iconTheme: const IconThemeData(color: _darkText, size: 24),
    chipTheme: ChipThemeData(
      backgroundColor: _darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: _darkOutline),
      labelStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: _darkText,
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentTextStyle: GoogleFonts.nunito(fontSize: 14),
      backgroundColor: _darkCard,
    ),
    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      backgroundColor: _darkSurface,
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: _darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      showDragHandle: true,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryVioletLight,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}
