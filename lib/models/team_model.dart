class TeamModel {
  final String name;
  final String shortName;
  final String? logoUrl;
  final String? flag;

  const TeamModel({
    required this.name,
    required this.shortName,
    this.logoUrl,
    this.flag,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      name: json['name'] as String? ?? '',
      shortName: json['shortName'] as String? ?? json['name'] as String? ?? '',
      logoUrl: json['logoUrl'] as String?,
      flag: json['flag'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'shortName': shortName,
      'logoUrl': logoUrl,
      'flag': flag,
    };
  }

  TeamModel copyWith({
    String? name,
    String? shortName,
    String? logoUrl,
    String? flag,
  }) {
    return TeamModel(
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      logoUrl: logoUrl ?? this.logoUrl,
      flag: flag ?? this.flag,
    );
  }
}
