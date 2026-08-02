import 'package:flutter/material.dart';

/// SprayLog brand theme. Light is the default; dark is a navy-charcoal
/// variant kept in sync through the shared [_build] component wiring.
class SpraylogTheme {
  const SpraylogTheme._();

  /// Primary navy blue.
  static const brandNavy = Color(0xFF1B3A5C);

  /// Deep navy — gradient stops, emphasis.
  static const brandNavyDeep = Color(0xFF0B1F33);

  /// Neutral gray for lines/borders.
  static const brandLine = Color(0xFF9AA3AD);

  /// Legacy turf greens — kept for history only, do not use in the UI.
  @Deprecated('use brandNavy')
  static const brandTurf = Color(0xFF2E7D32);

  /// Legacy turf green — kept for history only, do not use in the UI.
  @Deprecated('use brandNavyDeep')
  static const brandTurfDark = Color(0xFF1B5E20);

  /// Near-black green — primary text.
  static const brandInk = Color(0xFF1A2E1D);

  /// Warm off-white background with a green hint.
  static const brandMist = Color(0xFFF7F8F4);

  /// Warnings / flags only.
  static const brandAmber = Color(0xFFF9A825);
  static const brandSky = Color(0xFF4FC3F7);
  static const brandSkySoft = Color(0xFFE1F5FE);
  static const brandSkyDeep = Color(0xFF039BE5);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(seedColor: brandNavy).copyWith(
      primary: brandNavy,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDDE4EB),
      onPrimaryContainer: brandInk,
      secondary: brandInk,
      surface: brandMist,
      onSurface: brandInk,
    );
    return _build(scheme, inputFill: Colors.white);
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandNavy,
      brightness: Brightness.dark,
    ).copyWith(
      // True black canvas per user direction; cards lift off it slightly.
      primary: const Color(0xFF6C8FB0), // lighter navy for contrast on black
      onPrimary: Colors.black,
      primaryContainer: const Color(0xFF16324F),
      onPrimaryContainer: const Color(0xFFDDE4EB),
      secondary: brandSky,
      onSecondary: Colors.black,
      surface: const Color(0xFF0D1117), // very dark gray (user direction)
      onSurface: const Color(0xFFEAEFF4),
      surfaceContainerHighest: const Color(0xFF161B20),
    );
    return _build(scheme, inputFill: const Color(0xFF161B20));
  }

  static ThemeData _build(
    ColorScheme scheme, {
    required Color inputFill,
  }) {
    final rounded12 = BorderRadius.circular(12);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        shape: const Border(
          bottom: BorderSide(color: brandNavy, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: rounded12,
          side: BorderSide(color: brandLine.withValues(alpha: 0.6)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: rounded12,
          borderSide: const BorderSide(color: brandLine),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: rounded12,
          borderSide: const BorderSide(color: brandLine),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rounded12,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: const BorderSide(color: brandLine),
          shape: RoundedRectangleBorder(borderRadius: rounded12),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 48),
          elevation: 1,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: rounded12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size(64, 48),
          shape: RoundedRectangleBorder(borderRadius: rounded12),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: rounded12),
      ),
    );
  }
}
