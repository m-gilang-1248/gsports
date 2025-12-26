// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'court_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CourtModel _$CourtModelFromJson(Map<String, dynamic> json) => CourtModel(
  id: json['id'] as String,
  name: json['name'] as String,
  sportType: json['sportType'] as String,
  hourlyPrice: (json['hourlyPrice'] as num).toInt(),
  isActive: json['isActive'] as bool? ?? true,
  surfaceType: json['surfaceType'] as String? ?? 'Standard',
  isIndoor: json['isIndoor'] as bool? ?? true,
);

Map<String, dynamic> _$CourtModelToJson(CourtModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'sportType': instance.sportType,
      'hourlyPrice': instance.hourlyPrice,
      'isActive': instance.isActive,
      'surfaceType': instance.surfaceType,
      'isIndoor': instance.isIndoor,
    };
