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
    defaultValue: 'https://mljrlfxhyjegrmqdbscp.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1sanJsZnhoeWplZ3JtcWRic2NwIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTM1Njc4OTEsImV4cCI6MjEwOTE0Mzg5MX0.IFdEzlOgzxXba6K_l3s3OgurscfPn0ce9z-9uiS2FVE',
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
