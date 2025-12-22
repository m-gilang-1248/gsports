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

  const MatchResultModel({
    required super.id,
    required super.bookingId,
    required super.sportType,
    required super.playedAt,
    required this.setsModel,
    required super.winner,
  }) : super(sets: setsModel);

  factory MatchResultModel.fromJson(Map<String, dynamic> json) =>
      _$MatchResultModelFromJson(json);

  Map<String, dynamic> toJson() => _$MatchResultModelToJson(this);

  factory MatchResultModel.fromEntity(MatchResult entity) {
    return MatchResultModel(
      id: entity.id,
      bookingId: entity.bookingId,
      sportType: entity.sportType,
      playedAt: entity.playedAt,
      setsModel: entity.sets.map((e) => MatchSetModel.fromEntity(e)).toList(),
      winner: entity.winner,
    );
  }
}
