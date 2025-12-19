// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VenueModel _$VenueModelFromJson(Map<String, dynamic> json) => VenueModel(
  id: json['id'] as String,
  ownerId: json['ownerId'] as String,
  name: json['name'] as String,
  description: json['description'] as String,
  address: json['address'] as String,
  city: json['city'] as String,
  location: VenueModel._locationFromJson(
    json['location'] as Map<String, dynamic>,
  ),
  facilities: (json['facilities'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  photos: (json['photos'] as List<dynamic>).map((e) => e as String).toList(),
  rating: (json['rating'] as num).toDouble(),
  minPrice: (json['minPrice'] as num).toInt(),
  isVerified: json['isVerified'] as bool? ?? false,
);

Map<String, dynamic> _$VenueModelToJson(VenueModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ownerId': instance.ownerId,
      'name': instance.name,
      'description': instance.description,
      'address': instance.address,
      'city': instance.city,
      'facilities': instance.facilities,
      'photos': instance.photos,
      'rating': instance.rating,
      'minPrice': instance.minPrice,
      'isVerified': instance.isVerified,
      'location': VenueModel._locationToJson(instance.location),
    };
