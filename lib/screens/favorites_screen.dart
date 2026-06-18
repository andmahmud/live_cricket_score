import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/favorites_provider.dart';
import '../providers/match_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/match_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favProvider, _) {
              if (favProvider.favoritesCount > 0) {
                return IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _confirmClear(context, favProvider),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer2<MatchProvider, FavoritesProvider>(
        builder: (context, matchProvider, favProvider, _) {
          final favorites = favProvider.getFavoriteMatches(matchProvider.allMatches);

          if (favorites.isEmpty) {
            return const EmptyState(
              message: 'No favorite matches',
              icon: Icons.favorite_border,
              subtitle: 'Add matches to favorites by tapping the heart icon',
            );
          }

          if (matchProvider.isLoading && matchProvider.allMatches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () => matchProvider.refreshFromApi(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final match = favorites[index];
                return MatchCard(
                  match: match,
                  isFavorite: true,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      Routes.matchDetails,
                      arguments: match.id,
                    );
                  },
                  onFavoriteTap: () => favProvider.toggleFavorite(match.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _confirmClear(BuildContext context, FavoritesProvider favProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content:
            const Text('Are you sure you want to clear all favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              favProvider.clearFavorites();
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
