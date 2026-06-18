import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../models/match_model.dart';

class MatchCard extends StatelessWidget {
  final MatchModel match;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteTap;

  const MatchCard({
    super.key,
    required this.match,
    this.isFavorite = false,
    this.onTap,
    this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, isDark),
              const SizedBox(height: 12),
              _buildTeamsSection(context),
              const SizedBox(height: 12),
              _buildStatusSection(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        if (match.series?.name != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.series!.name!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.green[300] : const Color(0xFF2E7D32),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ),
        if (match.matchTypeDisplay.isNotEmpty) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white10 : Colors.orange[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match.matchTypeDisplay,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.orange[300] : Colors.orange[800],
              ),
            ),
          ),
        ],
        const Spacer(),
        if (match.matchStatus == MatchStatus.live)
          _buildLiveBadge(),
        if (onFavoriteTap != null)
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              size: 20,
              color: isFavorite ? Colors.red : Colors.grey,
            ),
            onPressed: onFavoriteTap,
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.only(left: 8),
          ),
      ],
    );
  }

  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'LIVE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamsSection(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildTeamColumn(
            context,
            match.teamA?.shortName ?? match.teamA?.name ?? 'Team A',
            match.teamAScore?.displayWithOvers ?? '',
            Colors.blue,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'VS',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[500],
            ),
          ),
        ),
        Expanded(
          child: _buildTeamColumn(
            context,
            match.teamB?.shortName ?? match.teamB?.name ?? 'Team B',
            match.teamBScore?.displayWithOvers ?? '',
            Colors.red,
            alignRight: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(
    BuildContext context,
    String teamName,
    String score,
    Color color, {
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          teamName,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          score,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: score.isEmpty ? Colors.grey : color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection(BuildContext context, bool isDark) {
    final statusText = match.statusNote ??
        match.result ??
        match.matchSummary ??
        '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (statusText.isNotEmpty)
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        if (match.venue != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Icon(
                  Icons.stadium_outlined,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    match.venue!,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class MatchCardShimmer extends StatelessWidget {
  const MatchCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 40,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 24,
                    height: 14,
                    color: Colors.white,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          width: 80,
                          height: 18,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 120,
                          height: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
