import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../providers/favorites_provider.dart';
import '../providers/match_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/match_card.dart';

class UpcomingMatchesScreen extends StatelessWidget {
  const UpcomingMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upcoming Matches')),
      body: Consumer<MatchProvider>(
        builder: (context, provider, _) {
          final matches = provider.upcomingMatches;

          if (provider.isLoading && matches.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (matches.isEmpty) {
            return const EmptyState(
              message: 'No upcoming matches',
              icon: Icons.event,
              subtitle: 'Scheduled matches will appear here',
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshFromApi(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return Consumer<FavoritesProvider>(
                  builder: (context, favProvider, _) {
                    return MatchCard(
                      match: match,
                      isFavorite: favProvider.isFavorite(match.id),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          Routes.matchDetails,
                          arguments: match.id,
                        );
                      },
                      onFavoriteTap: () =>
                          favProvider.toggleFavorite(match.id),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
