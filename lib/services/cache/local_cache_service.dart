import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../config/constants.dart';
import '../../models/match_model.dart';
import '../logging/logger_service.dart';

class LocalCacheService {
  late Box<String> _cacheBox;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _cacheBox = await Hive.openBox<String>(CacheConstants.hiveBoxName);
    _initialized = true;
    AppLogger.logInfo('Cache initialized');
  }

  bool get isInitialized => _initialized;

  Future<void> cacheLiveMatches(List<MatchModel> matches) async {
    if (!_initialized) return;
    try {
      final json = jsonEncode(matches.map((m) => m.toJson()).toList());
      await _cacheBox.put(CacheConstants.liveMatchesKey, json);
      AppLogger.logCacheUpdate(CacheConstants.liveMatchesKey, type: 'list');
    } catch (e) {
      AppLogger.logError('Failed to cache live matches', e);
    }
  }

  List<MatchModel>? getCachedLiveMatches() {
    try {
      final json = _cacheBox.get(CacheConstants.liveMatchesKey);
      if (json == null) return null;
      final List<dynamic> decoded = jsonDecode(json);
      return decoded
          .map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to load cached live matches', e);
      return null;
    }
  }

  Future<void> cacheMatchDetails(String matchId, MatchModel match) async {
    if (!_initialized) return;
    try {
      final key = '${CacheConstants.matchDetailsPrefix}$matchId';
      final json = jsonEncode(match.toJson());
      await _cacheBox.put(key, json);
      AppLogger.logCacheUpdate(key, type: 'detail');
    } catch (e) {
      AppLogger.logError('Failed to cache match details', e);
    }
  }

  MatchModel? getCachedMatchDetails(String matchId) {
    try {
      final key = '${CacheConstants.matchDetailsPrefix}$matchId';
      final json = _cacheBox.get(key);
      if (json == null) return null;
      return MatchModel.fromJson(
          jsonDecode(json) as Map<String, dynamic>);
    } catch (e) {
      AppLogger.logError('Failed to load cached match details', e);
      return null;
    }
  }

  Future<void> clearCache() async {
    if (!_initialized) return;
    try {
      await _cacheBox.clear();
      AppLogger.logInfo('Cache cleared');
    } catch (e) {
      AppLogger.logError('Failed to clear cache', e);
    }
  }

  Future<void> clearOldCache({Duration? maxAge}) async {
    if (!_initialized) return;
    AppLogger.logInfo('Old cache cleanup not implemented for Hive');
  }

  Future<void> dispose() async {
    if (_initialized) {
      await _cacheBox.close();
      _initialized = false;
    }
  }
}
