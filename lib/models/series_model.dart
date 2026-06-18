class SeriesModel {
  final String? id;
  final String? name;
  final String? shortName;
  final String? season;
  final String? status;

  const SeriesModel({
    this.id,
    this.name,
    this.shortName,
    this.season,
    this.status,
  });

  factory SeriesModel.fromJson(Map<String, dynamic> json) {
    return SeriesModel(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      shortName: json['shortName'] as String? ?? json['short_name'] as String?,
      season: json['season'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'shortName': shortName,
      'season': season,
      'status': status,
    };
  }

  SeriesModel copyWith({
    String? id,
    String? name,
    String? shortName,
    String? season,
    String? status,
  }) {
    return SeriesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      season: season ?? this.season,
      status: status ?? this.status,
    );
  }
}
