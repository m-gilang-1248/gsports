import 'package:equatable/equatable.dart';

class Court extends Equatable {
  final String id;
  final String name;
  final String sportType;
  final int hourlyPrice;
  final bool isActive;
  final String surfaceType;
  final bool isIndoor;
  final List<String> photos;
  final String description;

  const Court({
    required this.id,
    required this.name,
    required this.sportType,
    required this.hourlyPrice,
    this.isActive = true,
    this.surfaceType = 'Standard',
    this.isIndoor = true,
    this.photos = const [],
    this.description = '',
  });

  @override
  List<Object?> get props => [
        id,
        name,
        sportType,
        hourlyPrice,
        isActive,
        surfaceType,
        isIndoor,
        photos,
        description,
      ];
}