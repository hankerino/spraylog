import 'package:flutter/material.dart';

/// SprayLog brand theme. Light is the default; dark is a green-charcoal
/// variant kept in sync through the shared [_build] component wiring.
class SpraylogTheme {
  const SpraylogTheme._();

  /// Primary turf green.
  static const brandTurf = Color(0xFF2E7D32);

  /// Deep turf green — section headers, emphasis.
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
    final scheme = ColorScheme.fromSeed(seedColor: brandTurf).copyWith(
      primary: brandTurf,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFDCEBD8),
      onPrimaryContainer: brandInk,
      secondary: brandInk,
      surface: brandMist,
      onSurface: brandInk,
    );
    return _build(scheme, inputFill: Colors.white);
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: brandTurf,
      brightness: Brightness.dark,
    ).copyWith(
      primary: brandTurf,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF1E3D24),
      onPrimaryContainer: const Color(0xFFDCEBD8),
      secondary: const Color(0xFFB9CDBB),
      surface: const Color(0xFF141A15),
      onSurface: const Color(0xFFE8EDE6),
    );
    return _build(scheme, inputFill: const Color(0xFF1D241E));
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
          bottom: BorderSide(color: brandTurf, width: 3),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: rounded12,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFill,
        border: OutlineInputBorder(
          borderRadius: rounded12,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: rounded12,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: rounded12,
          borderSide: BorderSide(color: scheme.primary, width: 2),
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
