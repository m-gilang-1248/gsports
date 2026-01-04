// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_holiday_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueHolidayModel _$VenueHolidayModelFromJson(Map<String, dynamic> json) =>
    VenueHolidayModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
    );

Map<String, dynamic> _$VenueHolidayModelToJson(VenueHolidayModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
    };
