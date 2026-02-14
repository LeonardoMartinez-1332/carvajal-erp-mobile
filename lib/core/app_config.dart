class AppConfig {
  /// Cambia esto a `false` si quieres volver a usar local.
    static const bool useProduction = true;

    static const String _prodBaseUrl =
        'https://papayawhip-hedgehog-409976.hostingersite.com/api';

    // Para cuando quieras seguir probando local:
    static const String _localBaseUrl = 'http://127.0.0.1:8000/api';

    static String get apiBaseUrl =>
        useProduction ? _prodBaseUrl : _localBaseUrl;
}
