class ScoreModel {
  final String? runs;
  final String? wickets;
  final String? overs;
  final String? runRate;

  const ScoreModel({
    this.runs,
    this.wickets,
    this.overs,
    this.runRate,
  });

  factory ScoreModel.fromJson(Map<String, dynamic> json) {
    return ScoreModel(
      runs: json['runs']?.toString(),
      wickets: json['wickets']?.toString(),
      overs: json['overs']?.toString(),
      runRate: json['runRate']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'runs': runs,
      'wickets': wickets,
      'overs': overs,
      'runRate': runRate,
    };
  }

  String get display => runs != null ? '$runs/${wickets ?? "-"}' : '';
  String get displayWithOvers =>
      runs != null ? '$runs/${wickets ?? "-"} ($overs Ov)' : 'Yet to bat';

  ScoreModel copyWith({
    String? runs,
    String? wickets,
    String? overs,
    String? runRate,
  }) {
    return ScoreModel(
      runs: runs ?? this.runs,
      wickets: wickets ?? this.wickets,
      overs: overs ?? this.overs,
      runRate: runRate ?? this.runRate,
    );
  }
}

class BattingScoreModel {
  final String? name;
  final String? runs;
  final String? balls;
  final String? fours;
  final String? sixes;
  final String? sr;
  final String? outDescription;
  final bool isOut;

  const BattingScoreModel({
    this.name,
    this.runs,
    this.balls,
    this.fours,
    this.sixes,
    this.sr,
    this.outDescription,
    this.isOut = true,
  });

  factory BattingScoreModel.fromJson(Map<String, dynamic> json) {
    return BattingScoreModel(
      name: json['name'] as String?,
      runs: json['runs']?.toString(),
      balls: json['balls']?.toString(),
      fours: json['fours']?.toString(),
      sixes: json['sixes']?.toString(),
      sr: json['sr']?.toString() ?? json['strikeRate']?.toString(),
      outDescription: json['outDescription'] as String? ?? json['out'] as String?,
      isOut: json['isOut'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'runs': runs,
      'balls': balls,
      'fours': fours,
      'sixes': sixes,
      'sr': sr,
      'outDescription': outDescription,
      'isOut': isOut,
    };
  }
}

class BowlingScoreModel {
  final String? name;
  final String? overs;
  final String? maidens;
  final String? runs;
  final String? wickets;
  final String? economy;
  final String? wides;
  final String? noBalls;

  const BowlingScoreModel({
    this.name,
    this.overs,
    this.maidens,
    this.runs,
    this.wickets,
    this.economy,
    this.wides,
    this.noBalls,
  });

  factory BowlingScoreModel.fromJson(Map<String, dynamic> json) {
    return BowlingScoreModel(
      name: json['name'] as String?,
      overs: json['overs']?.toString(),
      maidens: json['maidens']?.toString() ?? json['m']?.toString(),
      runs: json['runs']?.toString(),
      wickets: json['wickets']?.toString() ?? json['w']?.toString(),
      economy: json['economy']?.toString() ?? json['econ']?.toString(),
      wides: json['wides']?.toString(),
      noBalls: json['noBalls']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'overs': overs,
      'maidens': maidens,
      'runs': runs,
      'wickets': wickets,
      'economy': economy,
      'wides': wides,
      'noBalls': noBalls,
    };
  }
}

class InningsScoreModel {
  final String? battingTeam;
  final String? bowlingTeam;
  final ScoreModel? score;
  final List<BattingScoreModel> batting;
  final List<BowlingScoreModel> bowling;
  final String? extras;

  const InningsScoreModel({
    this.battingTeam,
    this.bowlingTeam,
    this.score,
    this.batting = const [],
    this.bowling = const [],
    this.extras,
  });

  factory InningsScoreModel.fromJson(Map<String, dynamic> json) {
    return InningsScoreModel(
      battingTeam: json['battingTeam'] as String?,
      bowlingTeam: json['bowlingTeam'] as String?,
      score: json['score'] != null
          ? ScoreModel.fromJson(json['score'] as Map<String, dynamic>)
          : null,
      batting: (json['batting'] as List<dynamic>?)
              ?.map((e) =>
                  BattingScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bowling: (json['bowling'] as List<dynamic>?)
              ?.map((e) =>
                  BowlingScoreModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      extras: json['extras']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battingTeam': battingTeam,
      'bowlingTeam': bowlingTeam,
      'score': score?.toJson(),
      'batting': batting.map((e) => e.toJson()).toList(),
      'bowling': bowling.map((e) => e.toJson()).toList(),
      'extras': extras,
    };
  }
}
