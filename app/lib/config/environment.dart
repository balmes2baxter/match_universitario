import 'package:flutter/foundation.dart';

/// Configuración de entorno de la aplicación.
/// - En producción (rama main): corre sin datos mock (`ENABLE_MOCKS=false` o release).
/// - En desarrollo local (rama dev): corre con datos mock para testing interactivo.
abstract final class Environment {
  static const bool _hasMockOverride = bool.hasEnvironment('ENABLE_MOCKS');
  static const bool _mockOverride = bool.fromEnvironment('ENABLE_MOCKS');

  /// Indica si los datos de prueba (mocks) están activos.
  /// En modo debug / desarrollo local: `true`.
  /// En modo release / producción: `false` (salvo override explícito).
  static bool get isMockEnabled {
    if (_hasMockOverride) {
      return _mockOverride;
    }
    return kDebugMode;
  }

  /// Nombre del entorno actual.
  static String get name => isMockEnabled ? 'development' : 'production';

  /// Indica si estamos en producción real.
  static bool get isProduction => !isMockEnabled;
}
