import 'package:flutter/material.dart';

import '../models/score_model.dart';

class ScoreCard extends StatelessWidget {
  final List<InningsScoreModel> innings;
  final bool isLoading;

  const ScoreCard({
    super.key,
    required this.innings,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (innings.isEmpty) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No score data available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: innings.length,
      itemBuilder: (context, index) {
        final inn = innings[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInningsHeader(context, inn, index),
                  const Divider(),
                  _buildScoreSummary(inn),
                  const SizedBox(height: 16),
                  if (inn.batting.isNotEmpty) ...[
                    _buildSectionTitle(context, 'Batting'),
                    const SizedBox(height: 8),
                    _buildBattingTable(context, inn.batting),
                  ],
                  if (inn.bowling.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSectionTitle(context, 'Bowling'),
                    const SizedBox(height: 8),
                    _buildBowlingTable(context, inn.bowling),
                  ],
                  if (inn.extras != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Extras: ${inn.extras}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInningsHeader(
      BuildContext context, InningsScoreModel inn, int index) {
    final teamName = inn.battingTeam ?? 'Innings ${index + 1}';
    final score = inn.score;
    final scoreStr = score != null
        ? '${score.runs}/${score.wickets ?? ""} (${score.overs ?? ""} Ov)'
        : '';

    return Row(
      children: [
        Expanded(
          child: Text(
            teamName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (scoreStr.isNotEmpty)
          Text(
            scoreStr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  Widget _buildScoreSummary(InningsScoreModel inn) {
    if (inn.score?.runRate == null) return const SizedBox.shrink();
    return Row(
      children: [
        Text(
          'Run Rate: ${inn.score!.runRate}',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildBattingTable(
      BuildContext context, List<BattingScoreModel> batting) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          children: ['Batter', 'R', 'B', '4s', '6s', 'SR']
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      h,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ))
              .toList(),
        ),
        ...batting.map((b) => TableRow(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.name ?? '-',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (b.outDescription != null && b.outDescription!.isNotEmpty)
                      Text(
                        b.outDescription!,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[500],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
                _cell(b.runs ?? '0'),
                _cell(b.balls ?? '0'),
                _cell(b.fours ?? '0'),
                _cell(b.sixes ?? '0'),
                _cell(b.sr ?? '0'),
              ],
            )),
      ],
    );
  }

  Widget _buildBowlingTable(
      BuildContext context, List<BowlingScoreModel> bowling) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1.5),
      },
      children: [
        TableRow(
          children: ['Bowler', 'O', 'M', 'R', 'W', 'Econ']
              .map((h) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      h,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                  ))
              .toList(),
        ),
        ...bowling.map((b) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    b.name ?? '-',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                _cell(b.overs ?? '0'),
                _cell(b.maidens ?? '0'),
                _cell(b.runs ?? '0'),
                _cell(b.wickets ?? '0'),
                _cell(b.economy ?? '0'),
              ],
            )),
      ],
    );
  }

  Widget _cell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13),
        textAlign: TextAlign.center,
      ),
    );
  }
}
