class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://cricbuzz-live.vercel.app';
  static const String liveMatches = '/v1/matches/live';
  static String matchScore(String matchId) => '/v1/score/$matchId';
}

class CacheConstants {
  CacheConstants._();

  static const String hiveBoxName = 'cricket_cache';
  static const String liveMatchesKey = 'live_matches';
  static const String matchDetailsPrefix = 'match_detail_';
  static const Duration liveMatchRefreshDuration = Duration(seconds: 30);
  static const Duration noLiveMatchRefreshDuration = Duration(minutes: 5);
  static const Duration cacheExpiry = Duration(minutes: 5);
}

class AppConstants {
  AppConstants._();

  static const String appName = 'Live Cricket Score';
  static const String appVersion = '1.0.0';
}

