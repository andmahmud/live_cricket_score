class AppLogger {
  static void init() {}

  static void logApiRequest(String endpoint, {Map<String, dynamic>? params}) {
    _log('API Request: $endpoint | Params: $params');
  }

  static void logApiResponse(String endpoint, int statusCode,
      {String? response}) {
    _log('API Response: $endpoint | Status: $statusCode');
    if (response != null && response.length < 500) {
      _log('Response Body: $response');
    }
  }

  static void logRefresh(String source) {
    _log('Refresh Event: $source');
  }

  static void logCacheUpdate(String key, {String? type}) {
    _log('Cache Update: $key | Type: ${type ?? "unknown"}');
  }

  static void logError(String message, [dynamic error, StackTrace? stack]) {
    _log('Error: $message | ${error?.toString() ?? ""}');
  }

  static void logInfo(String message) {
    _log(message);
  }

  static void logDebug(String message) {
    _log('DEBUG: $message');
  }

  static void _log(String message) {
    print('[CricketApp] $message');
  }
}
