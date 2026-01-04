import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/venue.dart';
import '../../domain/entities/venue_location.dart';
import 'venue_holiday_model.dart';

part 'venue_model.g.dart';

@JsonSerializable()
class VenueModel extends Venue {
  @override
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final VenueLocation location;

  @override
  @JsonKey(fromJson: _holidaysFromJson, toJson: _holidaysToJson)
  final List<VenueHolidayModel> holidays;

  const VenueModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    required super.address,
    required super.city,
    required this.location,
    required super.facilities,
    super.sportCategories,
    required super.photos,
    required super.rating,
    required super.minPrice,
    super.isVerified = false,
    super.operatingHours,
    this.holidays = const [],
  }) : super(location: location, holidays: holidays);

  factory VenueModel.fromJson(Map<String, dynamic> json) =>
      _$VenueModelFromJson(json);

  Map<String, dynamic> toJson() => _$VenueModelToJson(this);

  factory VenueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VenueModel(
      id: doc.id,
      ownerId: data['ownerId'] as String? ?? '',
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      address: data['address'] as String? ?? '',
      city: data['city'] as String? ?? '',
      location: _locationFromGeoPoint(data['location'] as GeoPoint?),
      facilities: List<String>.from(data['facilities'] as List? ?? []),
      sportCategories: List<String>.from(
        data['sportCategories'] as List? ?? [],
      ),
      photos: List<String>.from(data['photos'] as List? ?? []),
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
      minPrice: (data['minPrice'] as num? ?? 0).toInt(),
      isVerified: data['isVerified'] as bool? ?? false,
      operatingHours: data['operatingHours'] as Map<String, dynamic>?,
      holidays: _holidaysFromList(data['holidays'] as List?),
    );
  }

  static List<VenueHolidayModel> _holidaysFromList(List? list) {
    if (list == null) return [];
    return list.map((item) {
      // Safely convert to Map<String, dynamic> handling LinkedMap or other Map types
      final map = Map<String, dynamic>.from(item as Map);
      return VenueHolidayModel(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        startDate: (map['startDate'] as Timestamp).toDate(),
        endDate: (map['endDate'] as Timestamp).toDate(),
      );
    }).toList();
  }

  static VenueLocation _locationFromGeoPoint(GeoPoint? geoPoint) {
    if (geoPoint == null) return const VenueLocation(lat: 0, lng: 0);
    return VenueLocation(lat: geoPoint.latitude, lng: geoPoint.longitude);
  }

  static VenueLocation _locationFromJson(Map<String, dynamic> json) {
    return VenueLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  static Map<String, dynamic> _locationToJson(VenueLocation location) {
    return {'lat': location.lat, 'lng': location.lng};
  }

  static List<VenueHolidayModel> _holidaysFromJson(List<dynamic> json) {
    return json
        .map((e) => VenueHolidayModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static List<Map<String, dynamic>> _holidaysToJson(
    List<VenueHolidayModel> holidays,
  ) {
    return holidays.map((e) => e.toJson()).toList();
  }
}
