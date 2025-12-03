import 'package:equatable/equatable.dart';

class VenueLocation extends Equatable {
  final double lat;
  final double lng;

  const VenueLocation({required this.lat, required this.lng});

  @override
  List<Object?> get props => [lat, lng];
}
