import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/venue.dart';
import '../../domain/entities/venue_location.dart';

part 'venue_model.g.dart';

VenueLocation _locationFromJson(dynamic json) {
  if (json is GeoPoint) {
    return VenueLocation(lat: json.latitude, lng: json.longitude);
  }
  if (json is Map<String, dynamic>) {
    return VenueLocation(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }
  return const VenueLocation(lat: 0, lng: 0);
}

dynamic _locationToJson(VenueLocation location) =>
    GeoPoint(location.lat, location.lng);

@JsonSerializable()
class VenueModel extends Venue {
  @override
  @JsonKey(includeToJson: false)
  final String id;

  @override
  final String name;

  @override
  final String description;

  @override
  final String address;

  @override
  final String city;

  @override
  @JsonKey(fromJson: _locationFromJson, toJson: _locationToJson)
  final VenueLocation location;

  @override
  final List<String> facilities;

  @override
  final List<String> photos;

  @override
  final double rating;

  @override
  final int minPrice;

  @override
  final bool isVerified;

  const VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.location,
    required this.facilities,
    required this.photos,
    required this.rating,
    required this.minPrice,
    required this.isVerified,
  }) : super(
         id: id,
         name: name,
         description: description,
         address: address,
         city: city,
         location: location,
         facilities: facilities,
         photos: photos,
         rating: rating,
         minPrice: minPrice,
         isVerified: isVerified,
       );

  factory VenueModel.fromJson(Map<String, dynamic> json) =>
      _$VenueModelFromJson(json);

  factory VenueModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VenueModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      location: data['location'] != null
          ? _locationFromJson(data['location'])
          : const VenueLocation(lat: 0, lng: 0),
      facilities: List<String>.from(data['facilities'] ?? []),
      photos: List<String>.from(data['photos'] ?? []),
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      minPrice: (data['minPrice'] as num?)?.toInt() ?? 0,
      isVerified: data['isVerified'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => _$VenueModelToJson(this);
}
