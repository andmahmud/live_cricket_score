import 'package:flutter/foundation.dart';

import '../models/match_model.dart';
import '../services/api/cricket_api_service.dart';
import '../services/cache/local_cache_service.dart';
import '../services/logging/logger_service.dart';

class MatchProvider extends ChangeNotifier {
  final CricketApiService _apiService;
  final LocalCacheService _cacheService;

  List<MatchModel> _allMatches = [];
  List<MatchModel> _liveMatches = [];
  List<MatchModel> _upcomingMatches = [];
  List<MatchModel> _recentResults = [];
  MatchModel? _selectedMatch;

  bool _isLoading = false;
  String? _error;
  bool _isOffline = false;
  bool _isAutoRefreshing = true;

  MatchProvider({
    required CricketApiService apiService,
    required LocalCacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  List<MatchModel> get allMatches => _allMatches;
  List<MatchModel> get liveMatches => _liveMatches;
  List<MatchModel> get upcomingMatches => _upcomingMatches;
  List<MatchModel> get recentResults => _recentResults;
  MatchModel? get selectedMatch => _selectedMatch;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isOffline => _isOffline;
  bool get isAutoRefreshing => _isAutoRefreshing;

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _loadFromCache();

    try {
      await refreshFromApi();
    } catch (e) {
      AppLogger.logError('Initial data load failed', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadFromCache() {
    try {
      final cached = _cacheService.getCachedLiveMatches();
      if (cached != null && cached.isNotEmpty) {
        _allMatches = cached;
        _categorizeMatches();
        _isOffline = true;
        AppLogger.logInfo('Loaded ${cached.length} matches from cache');
        notifyListeners();
      }
    } catch (e) {
      AppLogger.logError('Failed to load cache', e);
    }
  }

  Future<void> refreshFromApi() async {
    try {
      final matches = await _apiService.fetchAllMatches();
      if (matches.isNotEmpty) {
        _allMatches = matches;
        _categorizeMatches();
        _isOffline = false;
        _error = null;
        await _cacheService.cacheLiveMatches(matches);
        notifyListeners();
        AppLogger.logInfo('Fetched ${matches.length} matches from API');
      }
    } on ApiException catch (e) {
      _error = e.message;
      _isOffline = true;
      _loadFromCache();
      notifyListeners();
      AppLogger.logError('API error: ${e.message}');
    } catch (e) {
      _error = 'Failed to load matches';
      _isOffline = true;
      _loadFromCache();
      notifyListeners();
      AppLogger.logError('Unexpected error refreshing', e);
    }
  }

  Future<void> fetchMatchDetails(String matchId) async {
    _isLoading = true;
    notifyListeners();

    _selectedMatch = _cacheService.getCachedMatchDetails(matchId);

    try {
      final match = await _apiService.fetchMatchDetails(matchId);
      _selectedMatch = match;
      _error = null;
      await _cacheService.cacheMatchDetails(matchId, match);
      AppLogger.logInfo('Fetched details for match $matchId');
    } on ApiException catch (e) {
      _error = e.message;
      if (_selectedMatch == null) {
        _loadMatchFromAllMatches(matchId);
      }
      AppLogger.logError('Match detail fetch error: ${e.message}');
    } catch (e) {
      _error = 'Failed to load match details';
      if (_selectedMatch == null) {
        _loadMatchFromAllMatches(matchId);
      }
      AppLogger.logError('Unexpected error fetching match details', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadMatchFromAllMatches(String matchId) {
    try {
      final match = _allMatches.where((m) => m.id == matchId).firstOrNull;
      if (match != null) {
        _selectedMatch = match;
      }
    } catch (e) {
      AppLogger.logError('Failed to find match in list', e);
    }
  }

  void _categorizeMatches() {
    _liveMatches = _allMatches
        .where((m) => m.matchStatus == MatchStatus.live)
        .toList();
    _upcomingMatches = _allMatches
        .where((m) => m.matchStatus == MatchStatus.upcoming)
        .toList();
    _recentResults = _allMatches
        .where((m) => m.matchStatus == MatchStatus.completed)
        .toList();
  }

  void setAutoRefreshing(bool value) {
    _isAutoRefreshing = value;
    notifyListeners();
  }

  void startAutoRefresh() {
    _isAutoRefreshing = true;
    notifyListeners();
  }

  void stopAutoRefresh() {
    _isAutoRefreshing = false;
    notifyListeners();
  }

  void resumeAutoRefresh() {
    _isAutoRefreshing = true;
    notifyListeners();
  }
}
