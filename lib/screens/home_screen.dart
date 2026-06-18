import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/routes.dart';
import '../models/match_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/match_provider.dart';
import '../widgets/match_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MatchProvider>().loadInitialData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Cricket Score'),
        actions: [
          Consumer<MatchProvider>(
            builder: (_, provider, __) {
              if (provider.isOffline) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.wifi_off, color: Colors.orange, size: 20),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.pushNamed(context, Routes.favorites),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, Routes.settings),
          ),
        ],
      ),
      body: Consumer<MatchProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.allMatches.isEmpty) {
            return _buildLoadingShimmer();
          }

          if (provider.allMatches.isEmpty && provider.error != null) {
            return _buildErrorView(context, provider);
          }

          return RefreshIndicator(
            onRefresh: () => provider.refreshFromApi(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                if (provider.isOffline)
                  Container(
                    width: double.infinity,
                    color: Colors.orange[50],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.wifi_off, size: 16, color: Colors.orange[800]),
                        const SizedBox(width: 8),
                        Text(
                          'Showing cached data. Connect to internet for live scores.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                if (provider.liveMatches.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Live Matches', Icons.wifi_tethering,
                      color: Colors.red),
                  ...provider.liveMatches.map(
                    (match) => _buildMatchCard(context, match),
                  ),
                ],
                if (provider.upcomingMatches.isNotEmpty) ...[
                  _buildSectionHeader(context, 'Upcoming Matches',
                      Icons.schedule),
                  ...provider.upcomingMatches.map(
                    (match) => _buildMatchCard(context, match),
                  ),
                ],
                if (provider.recentResults.isNotEmpty) ...[
                  _buildSectionHeader(
                      context, 'Recent Results', Icons.history),
                  ...provider.recentResults.map(
                    (match) => _buildMatchCard(context, match),
                  ),
                ],
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) => const MatchCardShimmer(),
    );
  }

  Widget _buildErrorView(BuildContext context, MatchProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            provider.error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => provider.refreshFromApi(),
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, IconData icon,
      {Color? color}) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color ?? theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, MatchModel match) {
    return Consumer<FavoritesProvider>(
      builder: (context, favProvider, _) {
        final isFav = favProvider.isFavorite(match.id);
        return MatchCard(
          match: match,
          isFavorite: isFav,
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
    );
  }
}
