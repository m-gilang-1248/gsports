import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/entities/match_set.dart';

part 'match_result_model.g.dart';

@JsonSerializable(explicitToJson: true)
class MatchSetModel extends MatchSet {
  const MatchSetModel({required super.scoreA, required super.scoreB});

  factory MatchSetModel.fromJson(Map<String, dynamic> json) =>
      _$MatchSetModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchSetModelToJson(this);

  static MatchSetModel fromEntity(MatchSet entity) {
    return MatchSetModel(scoreA: entity.scoreA, scoreB: entity.scoreB);
  }
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) => timestamp.toDate();

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}

@JsonSerializable(explicitToJson: true)
@TimestampConverter()
class MatchResultModel extends MatchResult {
  final List<MatchSetModel> setsModel;

  @override
  @JsonKey(defaultValue: [])
  final List<String> teamAIds;

  @override
  @JsonKey(defaultValue: [])
  final List<String> teamBIds;

  @override
  @JsonKey(defaultValue: [])
  final List<String> players;

  @override
  @JsonKey(defaultValue: 'Team A')
  final String teamAName;

  @override
  @JsonKey(defaultValue: 'Team B')
  final String teamBName;

  @override
  @JsonKey(defaultValue: {})
  final Map<String, String> playerNames;

  const MatchResultModel({
    required super.id,
    required super.bookingId,
    required super.sportType,
    required super.playedAt,
    required super.durationSeconds,
    required this.players,
    required this.teamAIds,
    required this.teamBIds,
    required this.teamAName,
    required this.teamBName,
    required this.playerNames,
    super.venueName,
    super.courtName,
    super.startTime,
    super.endTime,
    required this.setsModel,
    required super.winner,
  }) : super(
         players: players,
         teamAIds: teamAIds,
         teamBIds: teamBIds,
         teamAName: teamAName,
         teamBName: teamBName,
         playerNames: playerNames,
         sets: setsModel,
       );

  factory MatchResultModel.fromJson(Map<String, dynamic> json) =>
      _$MatchResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchResultModelToJson(this);

  factory MatchResultModel.fromEntity(MatchResult entity) {
    return MatchResultModel(
      id: entity.id,
      bookingId: entity.bookingId,
      sportType: entity.sportType,
      playedAt: entity.playedAt,
      durationSeconds: entity.durationSeconds,
      players: entity.players,
      teamAIds: entity.teamAIds,
      teamBIds: entity.teamBIds,
      teamAName: entity.teamAName,
      teamBName: entity.teamBName,
      playerNames: entity.playerNames,
      venueName: entity.venueName,
      courtName: entity.courtName,
      startTime: entity.startTime,
      endTime: entity.endTime,
      setsModel: entity.sets.map((e) => MatchSetModel.fromEntity(e)).toList(),
      winner: entity.winner,
    );
  }
}
