class ApiConfig {
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static String get baseUrl {
    if (_rawBaseUrl.endsWith('/')) {
      return _rawBaseUrl.substring(0, _rawBaseUrl.length - 1);
    }
    return _rawBaseUrl;
  }
}
