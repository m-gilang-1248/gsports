// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_result_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MatchSetModel _$MatchSetModelFromJson(Map<String, dynamic> json) =>
    MatchSetModel(
      scoreA: (json['scoreA'] as num).toInt(),
      scoreB: (json['scoreB'] as num).toInt(),
    );

Map<String, dynamic> _$MatchSetModelToJson(MatchSetModel instance) =>
    <String, dynamic>{'scoreA': instance.scoreA, 'scoreB': instance.scoreB};

MatchResultModel _$MatchResultModelFromJson(Map<String, dynamic> json) =>
    MatchResultModel(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      sportType: json['sportType'] as String,
      playedAt: const TimestampConverter().fromJson(
        json['playedAt'] as Timestamp,
      ),
      setsModel: (json['setsModel'] as List<dynamic>)
          .map((e) => MatchSetModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      winner: json['winner'] as String,
    );

Map<String, dynamic> _$MatchResultModelToJson(MatchResultModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'sportType': instance.sportType,
      'playedAt': const TimestampConverter().toJson(instance.playedAt),
      'winner': instance.winner,
      'setsModel': instance.setsModel.map((e) => e.toJson()).toList(),
    };
