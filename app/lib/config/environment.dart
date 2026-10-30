/// Configuración de entorno y credenciales públicas de Supabase.
///
/// Las credenciales se pueden inyectar vía `--dart-define=SUPABASE_URL=...`
/// y `--dart-define=SUPABASE_ANON_KEY=...` o asignarse directamente en las
/// constantes por defecto una vez creado el proyecto en Supabase.
abstract final class Environment {
  static const bool _hasMockOverride = bool.hasEnvironment('ENABLE_MOCKS');
  static const bool _mockOverride = bool.fromEnvironment('ENABLE_MOCKS');

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Indica si hay una instancia de Supabase configurada.
  static bool get isSupabaseConfigured =>
      supabaseUrl.trim().isNotEmpty && supabaseAnonKey.trim().isNotEmpty;

  /// Indica si los datos semilla (convocatorias y matches del campus) están activos.
  static bool get isMockEnabled {
    if (_hasMockOverride) {
      return _mockOverride;
    }
    return true;
  }

  /// Nombre del entorno actual.
  static String get name => isSupabaseConfigured ? 'supabase_cloud' : 'demo_seeded';

  /// Indica si corre sin datos semilla.
  static bool get isProduction => !isMockEnabled;
}
