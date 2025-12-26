import 'package:equatable/equatable.dart';
import 'package:gsports/features/venue/domain/entities/venue_location.dart';

class Venue extends Equatable {
  final String id;
  final String ownerId; // Added ownerId
  final String name;
  final String description;
  final String address;
  final String city;
  final VenueLocation location;
  final List<String> facilities;
  final List<String> photos;
  final double rating;
  final int minPrice;
  final bool isVerified;
  final Map<String, dynamic>? operatingHours; // Added operatingHours

  const Venue({
    required this.id,
    required this.ownerId,
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
    this.operatingHours,
  });

  @override
  List<Object?> get props => [
    id,
    ownerId,
    name,
    description,
    address,
    city,
    location,
    facilities,
    photos,
    rating,
    minPrice,
    isVerified,
    operatingHours,
  ];
}
