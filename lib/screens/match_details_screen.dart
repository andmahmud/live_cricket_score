import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/match_model.dart';
import '../providers/favorites_provider.dart';
import '../providers/match_provider.dart';
import '../widgets/score_card.dart';
import '../widgets/error_display.dart';

class MatchDetailsScreen extends StatefulWidget {
  const MatchDetailsScreen({super.key});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final matchId = ModalRoute.of(context)?.settings.arguments as String?;
    if (matchId != null) {
      context.read<MatchProvider>().fetchMatchDetails(matchId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Consumer<MatchProvider>(
      builder: (context, provider, _) {
        final match = provider.selectedMatch;
        if (match == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Match Details')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${match.teamA?.shortName ?? "Team A"} vs ${match.teamB?.shortName ?? "Team B"}',
              style: const TextStyle(fontSize: 16),
            ),
            actions: [
              Consumer<FavoritesProvider>(
                builder: (context, favProvider, _) {
                  return IconButton(
                    icon: Icon(
                      favProvider.isFavorite(match.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: favProvider.isFavorite(match.id)
                          ? Colors.red
                          : null,
                    ),
                    onPressed: () => favProvider.toggleFavorite(match.id),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () => _shareMatch(match),
              ),
            ],
          ),
          body: provider.isLoading && match.innings == null
              ? const Center(child: CircularProgressIndicator())
              : provider.error != null && match.innings == null
                  ? ErrorDisplay(
                      message: provider.error!,
                      onRetry: () {
                        final matchId =
                            ModalRoute.of(context)?.settings.arguments
                                as String?;
                        if (matchId != null) {
                          provider.fetchMatchDetails(matchId);
                        }
                      },
                    )
                  : _buildDetailsContent(context, match, isDark),
        );
      },
    );
  }

  Widget _buildDetailsContent(
      BuildContext context, MatchModel match, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMatchHeader(context, match, isDark),
          _buildMatchInfo(context, match, isDark),
          if (match.matchSummary != null && match.matchSummary!.isNotEmpty)
            _buildSummarySection(context, match, isDark),
          if (match.tossWinner != null)
            _buildTossInfo(context, match, isDark),
          if (match.innings != null && match.innings!.isNotEmpty)
            ScoreCard(innings: match.innings!),
          if (match.innings == null || match.innings!.isEmpty)
            _buildNoScoreCard(context, match),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(BuildContext context, MatchModel match, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTeamDisplay(
                  match.teamA?.shortName ?? match.teamA?.name ?? 'Team A',
                  match.teamAScore?.display ?? '',
                  isDark,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[500],
                  ),
                ),
              ),
              Expanded(
                child: _buildTeamDisplay(
                  match.teamB?.shortName ?? match.teamB?.name ?? 'Team B',
                  match.teamBScore?.display ?? '',
                  isDark,
                  alignRight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusBadge(match),
        ],
      ),
    );
  }

  Widget _buildTeamDisplay(
    String name,
    String score,
    bool isDark, {
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (score.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            score,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge(MatchModel match) {
    Color badgeColor;
    String status;

    switch (match.matchStatus) {
      case MatchStatus.live:
        badgeColor = Colors.red;
        status = 'LIVE';
        break;
      case MatchStatus.completed:
        badgeColor = Colors.grey;
        status = 'COMPLETED';
        break;
      case MatchStatus.upcoming:
        badgeColor = Colors.blue;
        status = 'UPCOMING';
        break;
      case MatchStatus.unknown:
        badgeColor = Colors.grey;
        status = match.status?.toUpperCase() ?? '';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMatchInfo(BuildContext context, MatchModel match, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (match.series?.name != null)
            _infoRow(Icons.emoji_events, match.series!.name!, isDark),
          if (match.venue != null)
            _infoRow(Icons.stadium, match.venue!, isDark),
          if (match.statusNote != null)
            _infoRow(Icons.info_outline, match.statusNote!, isDark),
          if (match.result != null)
            _infoRow(
              Icons.flag,
              match.result!,
              isDark,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, bool isDark, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color ?? Colors.grey[500]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: color ?? (isDark ? Colors.grey[300] : Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
      BuildContext context, MatchModel match, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Match Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                match.matchSummary!,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTossInfo(
      BuildContext context, MatchModel match, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.monetization_on,
                size: 20,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${match.tossWinner} won the toss and opted to ${match.tossDecision}',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoScoreCard(BuildContext context, MatchModel match) {
    if (match.matchStatus == MatchStatus.upcoming) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Text(
            'Match not started yet',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Text(
          providerError ?? 'Scorecard loading...',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
    );
  }

  String? get providerError {
    return context.read<MatchProvider>().error;
  }

  void _shareMatch(MatchModel match) {
    final text = StringBuffer();
    text.writeln(
        '🏏 ${match.teamA?.shortName ?? "Team A"} vs ${match.teamB?.shortName ?? "Team B"}');
    if (match.teamAScore?.display != null) {
      text.writeln(
          '${match.teamA?.shortName}: ${match.teamAScore?.displayWithOvers}');
    }
    if (match.teamBScore?.display != null) {
      text.writeln(
          '${match.teamB?.shortName}: ${match.teamBScore?.displayWithOvers}');
    }
    if (match.statusNote != null) {
      text.writeln(match.statusNote);
    }
    text.writeln('Live Cricket Score');
    Share.share(text.toString());
  }
}
