part of 'venue_bloc.dart';

abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object> get props => [];
}

class VenueFetchListRequested extends VenueEvent {}

class VenueSearchRequested extends VenueEvent {
  final String query;
  final String? sportType;
  final String? city;
  final List<String>? facilities;
  final DateTime? date;

  const VenueSearchRequested({
    required this.query,
    this.sportType,
    this.city,
    this.facilities,
    this.date,
  });

  @override
  List<Object> get props => [
    query,
    sportType ?? '',
    city ?? '',
    facilities ?? [],
    date ?? '',
  ];
}

class VenueLocationDetected extends VenueEvent {
  final double lat;
  final double lng;
  final String? cityName;

  const VenueLocationDetected({
    required this.lat,
    required this.lng,
    this.cityName,
  });

  @override
  List<Object> get props => [lat, lng, cityName ?? ''];
}

class VenueFetchDetailRequested extends VenueEvent {
  final String venueId;

  const VenueFetchDetailRequested(this.venueId);

  @override
  List<Object> get props => [venueId];
}
