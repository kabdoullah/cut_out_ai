import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // Brand palette
  static const Color primaryViolet = Color(0xFF7C3AED);
  static const Color primaryVioletLight = Color(0xFF8B5CF6);
  static const Color accentFuchsia = Color(0xFFD946EF);
  static const Color accentCyan = Color(0xFF22D3EE);
  static const Color errorRed = Color(0xFFEF4444);

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

  static const ColorScheme _brandLightScheme = ColorScheme.light(
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
  );

  static const ColorScheme _brandDarkScheme = ColorScheme.dark(
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
  );

  // Manually-tuned surfaces that aren't part of ColorScheme (M3 folded
  // "background" into "surface"). Brand mode keeps its own tinted values;
  // a dynamic (Material You) scheme has no equivalent, so it derives these
  // from the scheme itself.
  static const _SurfaceTokens _brandLightTokens = _SurfaceTokens(
    background: _lightBg,
    card: _lightCard,
  );

  static const _SurfaceTokens _brandDarkTokens = _SurfaceTokens(
    background: _darkBg,
    card: _darkCard,
  );

  /// Light theme. Pass a harmonized dynamic [ColorScheme] (e.g. from
  /// `DynamicColorBuilder`) to theme the app from the system wallpaper
  /// (Material You) instead of the brand palette.
  static ThemeData light([ColorScheme? dynamicScheme]) {
    if (dynamicScheme == null) {
      return _build(_brandLightScheme, _brandLightTokens);
    }
    return _build(dynamicScheme, _SurfaceTokens.fromScheme(dynamicScheme));
  }

  /// Dark theme. Pass a harmonized dynamic [ColorScheme] (e.g. from
  /// `DynamicColorBuilder`) to theme the app from the system wallpaper
  /// (Material You) instead of the brand palette.
  static ThemeData dark([ColorScheme? dynamicScheme]) {
    if (dynamicScheme == null) {
      return _build(_brandDarkScheme, _brandDarkTokens);
    }
    return _build(dynamicScheme, _SurfaceTokens.fromScheme(dynamicScheme));
  }

  static TextTheme _textTheme(Color color) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 56,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        color: color,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: color,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: color,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: color,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 26,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: color,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: color,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: color,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: color,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: color,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: color,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: color,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
        color: color,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Outfit',
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.6,
        color: color,
      ),
    ).apply(bodyColor: color, displayColor: color, decorationColor: color);
  }

  static ThemeData _build(ColorScheme colorScheme, _SurfaceTokens tokens) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      textTheme: _textTheme(colorScheme.onSurface),
      colorScheme: colorScheme,
      scaffoldBackgroundColor: tokens.background,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: tokens.background,
        foregroundColor: colorScheme.onSurface,
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: -0.2,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: colorScheme.outline),
        ),
        color: colorScheme.surface,
        shadowColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: BorderSide(color: colorScheme.outline),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        space: 1,
        thickness: 1,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface, size: 24),
      chipTheme: ChipThemeData(
        backgroundColor: tokens.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide(color: colorScheme.outline),
        labelStyle: TextStyle(
          fontFamily: 'Outfit',
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: const TextStyle(fontFamily: 'Nunito', fontSize: 14),
        backgroundColor: isDark ? tokens.card : null,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        backgroundColor: colorScheme.surface,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

// Surfaces that Material 3's ColorScheme doesn't model on its own
// (scaffold "background" and the tinted card fill used for inputs/chips).
class _SurfaceTokens {
  final Color background;
  final Color card;

  const _SurfaceTokens({required this.background, required this.card});

  factory _SurfaceTokens.fromScheme(ColorScheme scheme) {
    return _SurfaceTokens(
      background: scheme.surface,
      card: scheme.surfaceContainerHighest,
    );
  }
}
