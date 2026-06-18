import 'dart:async';

import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../models/match_model.dart';
import '../../providers/match_provider.dart';
import '../api/cricket_api_service.dart';
import '../cache/local_cache_service.dart';
import '../logging/logger_service.dart';

class SyncService with WidgetsBindingObserver {
  final CricketApiService _apiService;
  final MatchProvider _matchProvider;

  Timer? _refreshTimer;
  bool _isInBackground = false;
  bool _isSyncing = false;

  SyncService({
    required CricketApiService apiService,
    required LocalCacheService cacheService,
    required MatchProvider matchProvider,
  })  : _apiService = apiService,
        _matchProvider = matchProvider;

  void startAutoRefresh() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    AppLogger.logInfo('Auto-refresh started');
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    WidgetsBinding.instance.removeObserver(this);
    AppLogger.logInfo('Auto-refresh stopped');
  }

  void _startTimer() {
    _refreshTimer?.cancel();
    final hasLive = _matchProvider.liveMatches.isNotEmpty;
    final duration = hasLive
        ? CacheConstants.liveMatchRefreshDuration
        : CacheConstants.noLiveMatchRefreshDuration;

    _refreshTimer = Timer.periodic(duration, (_) => _performSync());
    AppLogger.logDebug('Timer set: ${duration.inSeconds}s (live: $hasLive)');
  }

  Future<void> _performSync() async {
    if (_isSyncing || _isInBackground) return;
    _isSyncing = true;

    try {
      AppLogger.logRefresh('auto-sync');
      await _matchProvider.refreshFromApi();
      _startTimer();
    } catch (e) {
      AppLogger.logError('Auto-sync failed', e);
      _startTimer();
    } finally {
      _isSyncing = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _isInBackground = true;
      _refreshTimer?.cancel();
      _matchProvider.setAutoRefreshing(false);
      AppLogger.logInfo('App in background - refresh paused');
    } else if (state == AppLifecycleState.resumed) {
      _isInBackground = false;
      _matchProvider.setAutoRefreshing(true);
      _performSync();
      _startTimer();
      AppLogger.logInfo('App in foreground - refresh resumed');
    }
  }

  Future<void> manualRefresh() async {
    AppLogger.logRefresh('manual');
    await _performSync();
  }

  Future<List<MatchModel>> getLiveMatches() async {
    try {
      final matches = await _apiService.fetchAllMatches();
      return matches
          .where((m) => m.matchStatus == MatchStatus.live)
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch live matches', e);
      return [];
    }
  }

  Future<List<MatchModel>> getUpcomingMatches() async {
    try {
      final matches = await _apiService.fetchAllMatches();
      return matches
          .where((m) => m.matchStatus == MatchStatus.upcoming)
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch upcoming matches', e);
      return [];
    }
  }

  Future<List<MatchModel>> getRecentResults() async {
    try {
      final matches = await _apiService.fetchAllMatches();
      return matches
          .where((m) => m.matchStatus == MatchStatus.completed)
          .toList();
    } catch (e) {
      AppLogger.logError('Failed to fetch recent results', e);
      return [];
    }
  }

  void dispose() {
    stopAutoRefresh();
    _apiService.dispose();
  }
}
