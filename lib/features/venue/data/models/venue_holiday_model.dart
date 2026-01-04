import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/venue_holiday.dart';

part 'venue_holiday_model.g.dart';

@JsonSerializable()
class VenueHolidayModel extends VenueHoliday {
  const VenueHolidayModel({
    required super.id,
    required super.name,
    required super.startDate,
    required super.endDate,
  });

  factory VenueHolidayModel.fromJson(Map<String, dynamic> json) =>
      _$VenueHolidayModelFromJson(json);

  Map<String, dynamic> toJson() => _$VenueHolidayModelToJson(this);

  factory VenueHolidayModel.fromEntity(VenueHoliday entity) {
    return VenueHolidayModel(
      id: entity.id,
      name: entity.name,
      startDate: entity.startDate,
      endDate: entity.endDate,
    );
  }
}
