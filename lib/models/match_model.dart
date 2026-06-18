import 'team_model.dart';
import 'score_model.dart';
import 'series_model.dart';

enum MatchStatus { live, upcoming, completed, unknown }

enum MatchType { t20, odi, test, t10, theHundred, unknown }

class MatchModel {
  final String id;
  final String? title;
  final String? subtitle;
  final TeamModel? teamA;
  final TeamModel? teamB;
  final ScoreModel? teamAScore;
  final ScoreModel? teamBScore;
  final SeriesModel? series;
  final String? venue;
  final String? matchType;
  final String? status;
  final String? statusNote;
  final String? currentInning;
  final String? result;
  final String? tossWinner;
  final String? tossDecision;
  final String? matchDaysRemaining;
  final List<InningsScoreModel>? innings;
  final String? matchSummary;
  final bool isFavorite;

  const MatchModel({
    required this.id,
    this.title,
    this.subtitle,
    this.teamA,
    this.teamB,
    this.teamAScore,
    this.teamBScore,
    this.series,
    this.venue,
    this.matchType,
    this.status,
    this.statusNote,
    this.currentInning,
    this.result,
    this.tossWinner,
    this.tossDecision,
    this.matchDaysRemaining,
    this.innings,
    this.matchSummary,
    this.isFavorite = false,
  });

  MatchStatus get matchStatus {
    if (status == null) return MatchStatus.unknown;
    final s = status!.toLowerCase();
    if (s == 'live' || s == 'inprogress') return MatchStatus.live;
    if (s == 'upcoming' || s == 'scheduled') return MatchStatus.upcoming;
    if (s == 'completed' || s == 'complete' || s == 'finished') {
      return MatchStatus.completed;
    }
    return MatchStatus.unknown;
  }

  MatchType get type {
    if (matchType == null) return MatchType.unknown;
    final t = matchType!.toLowerCase();
    if (t.contains('t20')) return MatchType.t20;
    if (t.contains('odi') || t.contains('oda')) return MatchType.odi;
    if (t.contains('test')) return MatchType.test;
    if (t.contains('t10')) return MatchType.t10;
    if (t.contains('the hundred') || t.contains('hundred')) {
      return MatchType.theHundred;
    }
    return MatchType.unknown;
  }

  String get matchTypeDisplay {
    switch (type) {
      case MatchType.t20:
        return 'T20';
      case MatchType.odi:
        return 'ODI';
      case MatchType.test:
        return 'TEST';
      case MatchType.t10:
        return 'T10';
      case MatchType.theHundred:
        return 'The Hundred';
      case MatchType.unknown:
        return matchType ?? '';
    }
  }

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String? ?? json['subTitle'] as String?,
      teamA: json['teamA'] != null
          ? TeamModel.fromJson(json['teamA'] as Map<String, dynamic>)
          : null,
      teamB: json['teamB'] != null
          ? TeamModel.fromJson(json['teamB'] as Map<String, dynamic>)
          : null,
      teamAScore: json['teamAScore'] != null
          ? ScoreModel.fromJson(json['teamAScore'] as Map<String, dynamic>)
          : null,
      teamBScore: json['teamBScore'] != null
          ? ScoreModel.fromJson(json['teamBScore'] as Map<String, dynamic>)
          : null,
      series: json['series'] != null
          ? SeriesModel.fromJson(json['series'] as Map<String, dynamic>)
          : json['seriesName'] != null
              ? SeriesModel(name: json['seriesName'] as String)
              : null,
      venue: json['venue'] as String?,
      matchType: json['matchType'] as String? ?? json['type'] as String?,
      status: json['status'] as String?,
      statusNote:
          json['statusNote'] as String? ?? json['matchStatus'] as String?,
      currentInning: json['currentInning'] as String?,
      result: json['result'] as String?,
      tossWinner: json['tossWinner'] as String?,
      tossDecision: json['tossDecision'] as String?,
      matchDaysRemaining: json['matchDaysRemaining']?.toString(),
      innings: (json['innings'] as List<dynamic>?)
          ?.map(
              (e) => InningsScoreModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      matchSummary: json['matchSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'teamA': teamA?.toJson(),
      'teamB': teamB?.toJson(),
      'teamAScore': teamAScore?.toJson(),
      'teamBScore': teamBScore?.toJson(),
      'series': series?.toJson(),
      'venue': venue,
      'matchType': matchType,
      'status': status,
      'statusNote': statusNote,
      'currentInning': currentInning,
      'result': result,
      'tossWinner': tossWinner,
      'tossDecision': tossDecision,
      'matchDaysRemaining': matchDaysRemaining,
      'innings': innings?.map((e) => e.toJson()).toList(),
      'matchSummary': matchSummary,
      'isFavorite': isFavorite,
    };
  }

  MatchModel copyWith({
    String? id,
    String? title,
    String? subtitle,
    TeamModel? teamA,
    TeamModel? teamB,
    ScoreModel? teamAScore,
    ScoreModel? teamBScore,
    SeriesModel? series,
    String? venue,
    String? matchType,
    String? status,
    String? statusNote,
    String? currentInning,
    String? result,
    String? tossWinner,
    String? tossDecision,
    String? matchDaysRemaining,
    List<InningsScoreModel>? innings,
    String? matchSummary,
    bool? isFavorite,
  }) {
    return MatchModel(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      teamA: teamA ?? this.teamA,
      teamB: teamB ?? this.teamB,
      teamAScore: teamAScore ?? this.teamAScore,
      teamBScore: teamBScore ?? this.teamBScore,
      series: series ?? this.series,
      venue: venue ?? this.venue,
      matchType: matchType ?? this.matchType,
      status: status ?? this.status,
      statusNote: statusNote ?? this.statusNote,
      currentInning: currentInning ?? this.currentInning,
      result: result ?? this.result,
      tossWinner: tossWinner ?? this.tossWinner,
      tossDecision: tossDecision ?? this.tossDecision,
      matchDaysRemaining: matchDaysRemaining ?? this.matchDaysRemaining,
      innings: innings ?? this.innings,
      matchSummary: matchSummary ?? this.matchSummary,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
