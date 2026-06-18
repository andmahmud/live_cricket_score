import 'package:flutter/foundation.dart';

import '../models/match_model.dart';
import '../services/logging/logger_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final Set<String> _favoriteIds = {};

  Set<String> get favoriteIds => Set.unmodifiable(_favoriteIds);
  int get favoritesCount => _favoriteIds.length;

  bool isFavorite(String matchId) => _favoriteIds.contains(matchId);

  void toggleFavorite(String matchId) {
    if (_favoriteIds.contains(matchId)) {
      _favoriteIds.remove(matchId);
      AppLogger.logInfo('Removed match $matchId from favorites');
    } else {
      _favoriteIds.add(matchId);
      AppLogger.logInfo('Added match $matchId to favorites');
    }
    notifyListeners();
  }

  void addFavorite(String matchId) {
    _favoriteIds.add(matchId);
    AppLogger.logInfo('Added match $matchId to favorites');
    notifyListeners();
  }

  void removeFavorite(String matchId) {
    _favoriteIds.remove(matchId);
    AppLogger.logInfo('Removed match $matchId from favorites');
    notifyListeners();
  }

  void clearFavorites() {
    _favoriteIds.clear();
    AppLogger.logInfo('Favorites cleared');
    notifyListeners();
  }

  List<MatchModel> getFavoriteMatches(List<MatchModel> allMatches) {
    return allMatches
        .where((m) => _favoriteIds.contains(m.id))
        .toList();
  }
}
