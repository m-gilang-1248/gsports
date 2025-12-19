import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/venue.dart';
import '../../domain/entities/venue_location.dart';

part 'venue_model.g.dart';

@JsonSerializable()
class VenueModel extends Venue {
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  @override
  final VenueLocation location;

  const VenueModel({
    required super.id,
    required super.ownerId,
    required super.name,
    required super.description,
    required super.address,
    required super.city,
    required this.location,
    required super.facilities,
    required super.photos,
    required super.rating,
    required super.minPrice,
    super.isVerified = false,
  }) : super(location: location);

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
      photos: List<String>.from(data['photos'] as List? ?? []),
      rating: (data['rating'] as num? ?? 0.0).toDouble(),
      minPrice: (data['minPrice'] as num? ?? 0).toInt(),
      isVerified: data['isVerified'] as bool? ?? false,
    );
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
}
