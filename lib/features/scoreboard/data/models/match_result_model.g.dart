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

MatchResultModel _$MatchResultModelFromJson(
  Map<String, dynamic> json,
) => MatchResultModel(
  id: json['id'] as String,
  bookingId: json['bookingId'] as String,
  sportType: json['sportType'] as String,
  playedAt: const TimestampConverter().fromJson(json['playedAt'] as Timestamp),
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  players:
      (json['players'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  teamAIds:
      (json['teamAIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  teamBIds:
      (json['teamBIds'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  teamAName: json['teamAName'] as String? ?? 'Team A',
  teamBName: json['teamBName'] as String? ?? 'Team B',
  playerNames:
      (json['playerNames'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      {},
  venueName: json['venueName'] as String?,
  courtName: json['courtName'] as String?,
  startTime: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['startTime'],
    const TimestampConverter().fromJson,
  ),
  endTime: _$JsonConverterFromJson<Timestamp, DateTime>(
    json['endTime'],
    const TimestampConverter().fromJson,
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
      'durationSeconds': instance.durationSeconds,
      'venueName': instance.venueName,
      'courtName': instance.courtName,
      'startTime': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.startTime,
        const TimestampConverter().toJson,
      ),
      'endTime': _$JsonConverterToJson<Timestamp, DateTime>(
        instance.endTime,
        const TimestampConverter().toJson,
      ),
      'winner': instance.winner,
      'setsModel': instance.setsModel.map((e) => e.toJson()).toList(),
      'teamAIds': instance.teamAIds,
      'teamBIds': instance.teamBIds,
      'players': instance.players,
      'teamAName': instance.teamAName,
      'teamBName': instance.teamBName,
      'playerNames': instance.playerNames,
    };

Value? _$JsonConverterFromJson<Json, Value>(
  Object? json,
  Value? Function(Json json) fromJson,
) => json == null ? null : fromJson(json as Json);

Json? _$JsonConverterToJson<Json, Value>(
  Value? value,
  Json? Function(Value value) toJson,
) => value == null ? null : toJson(value);
