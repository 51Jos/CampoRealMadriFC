/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Sintético Lima';
  static const String appVersion = '1.0.0';

  // API
  static const String baseUrl = 'https://api.example.com';
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Cache
  static const String cacheKey = 'app_cache';
  static const int cacheValidityDuration = 3600; // segundos

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
}
