import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:match_universitario_app/theme/app_theme.dart';

double _lum(Color c) {
  double ch(int v) {
    final s = v / 255.0;
    return s <= 0.03928
        ? s / 12.92
        : math.pow((s + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * ch((c.toARGB32() >> 16) & 0xFF) +
      0.7152 * ch((c.toARGB32() >> 8) & 0xFF) +
      0.0722 * ch(c.toARGB32() & 0xFF);
}

double _ratio(Color a, Color b) {
  final l1 = _lum(a);
  final l2 = _lum(b);
  return (math.max(l1, l2) + 0.05) / (math.min(l1, l2) + 0.05);
}

void _expectAA(ColorScheme s, {required String name}) {
  final pairs = <String, List<Color>>{
    'primary/onPrimary': [s.primary, s.onPrimary],
    'secondary/onSecondary': [s.secondary, s.onSecondary],
    'tertiary/onTertiary': [s.tertiary, s.onTertiary],
    'primaryContainer/onPrimaryContainer': [
      s.primaryContainer,
      s.onPrimaryContainer,
    ],
    'secondaryContainer/onSecondaryContainer': [
      s.secondaryContainer,
      s.onSecondaryContainer,
    ],
    'tertiaryContainer/onTertiaryContainer': [
      s.tertiaryContainer,
      s.onTertiaryContainer,
    ],
  };
  pairs.forEach((label, colors) {
    final r = _ratio(colors[0], colors[1]);
    expect(
      r,
      greaterThanOrEqualTo(4.5),
      reason: '$name $label ratio=${r.toStringAsFixed(2)}',
    );
  });
}

void main() {
  test('Tema claro mantiene contraste AA en roles de acento', () {
    _expectAA(AppTheme.light.colorScheme, name: 'light');
  });

  test('Tema oscuro mantiene contraste AA en roles de acento', () {
    _expectAA(AppTheme.dark.colorScheme, name: 'dark');
  });

  test('Los acentos son cálidos (matiz naranja/amarillo)', () {
    final scheme = AppTheme.light.colorScheme;
    for (final color in [scheme.primary, scheme.secondary, scheme.tertiary]) {
      final hue = HSLColor.fromColor(color).hue;
      expect(
        hue,
        inInclusiveRange(20, 60),
        reason:
            'Hue $hue fuera del rango cálido para #${color.toARGB32().toRadixString(16)}',
      );
    }
  });
}
