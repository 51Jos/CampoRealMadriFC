/// Configuración de entornos (dev, staging, prod)
enum Environment {
  development,
  staging,
  production,
}

class EnvConfig {
  static Environment _currentEnv = Environment.development;

  static Environment get currentEnv => _currentEnv;

  static void setEnvironment(Environment env) {
    _currentEnv = env;
  }

  static bool get isDevelopment => _currentEnv == Environment.development;
  static bool get isStaging => _currentEnv == Environment.staging;
  static bool get isProduction => _currentEnv == Environment.production;

  // URLs por ambiente
  static String get baseUrl {
    switch (_currentEnv) {
      case Environment.development:
        return 'https://dev-api.sinteticolima.com';
      case Environment.staging:
        return 'https://staging-api.sinteticolima.com';
      case Environment.production:
        return 'https://api.sinteticolima.com';
    }
  }
}
