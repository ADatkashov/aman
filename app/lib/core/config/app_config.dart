/// Build-time configuration, supplied with `--dart-define`.
///
/// * `AMAN_API_MODE`  — `demo` (default, in-memory synthetic data) or `remote`.
/// * `AMAN_API_URL`   — base URL of the Spring Boot API (HTTPS in production).
/// * `AMAN_MAPS_PROVIDER` — `demo`, `2gis` or `google` (route deep links).
class AppConfig {
  const AppConfig({
    this.apiMode = const String.fromEnvironment('AMAN_API_MODE', defaultValue: 'demo'),
    this.apiBaseUrl = const String.fromEnvironment(
      'AMAN_API_URL',
      defaultValue: 'http://10.0.2.2:8080/api/v1',
    ),
    this.mapsProvider = const String.fromEnvironment('AMAN_MAPS_PROVIDER', defaultValue: '2gis'),
  });

  final String apiMode;
  final String apiBaseUrl;
  final String mapsProvider;

  bool get isDemo => apiMode != 'remote';
}
