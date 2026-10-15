import 'package:flutter/material.dart';

/// Paleta cálida (amarillos y naranjas) para Match Universitario.
///
/// Se parte de un esquema generado con [ColorScheme.fromSeed] usando la
/// variante `vibrant` para conservar superficies armónicas y neutras, y luego
/// se sobrescriben únicamente los roles de acento con tonos vivos pero
/// validados (contraste WCAG AA) para que no se vean saturados.
abstract final class AppTheme {
  static const Color _seed = Color(0xFFF57C00);

  static ThemeData get light {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    final scheme = base.copyWith(
      primary: const Color(0xFFEA6A00),
      onPrimary: const Color(0xFF3A1B00),
      primaryContainer: const Color(0xFFFFDDB8),
      onPrimaryContainer: const Color(0xFF2E1500),
      secondary: const Color(0xFFC77800),
      onSecondary: const Color(0xFF2B1A00),
      secondaryContainer: const Color(0xFFFFE7A3),
      onSecondaryContainer: const Color(0xFF2A1C00),
      tertiary: const Color(0xFFD14900),
      onTertiary: const Color(0xFFFFFFFF),
      tertiaryContainer: const Color(0xFFFFDCC8),
      onTertiaryContainer: const Color(0xFF351000),
    );
    return _themeFrom(scheme);
  }

  static ThemeData get dark {
    final base = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
      dynamicSchemeVariant: DynamicSchemeVariant.vibrant,
    );
    final scheme = base.copyWith(
      primary: const Color(0xFFFFB870),
      onPrimary: const Color(0xFF4A2400),
      primaryContainer: const Color(0xFF7A3A00),
      onPrimaryContainer: const Color(0xFFFFDDB8),
      secondary: const Color(0xFFFFCF7A),
      onSecondary: const Color(0xFF3A2600),
      secondaryContainer: const Color(0xFF5C4200),
      onSecondaryContainer: const Color(0xFFFFE7A3),
      tertiary: const Color(0xFFFFB59A),
      onTertiary: const Color(0xFF5A1D00),
      tertiaryContainer: const Color(0xFF7A2E00),
      onTertiaryContainer: const Color(0xFFFFDCC8),
    );
    return _themeFrom(scheme);
  }

  static ThemeData _themeFrom(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        clipBehavior: Clip.antiAlias,
      ),
    );
  }
}
