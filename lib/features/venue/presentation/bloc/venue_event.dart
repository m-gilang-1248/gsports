part of 'venue_bloc.dart';

abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object> get props => [];
}

class VenueFetchListRequested extends VenueEvent {}

class VenueFetchDetailRequested extends VenueEvent {
  final String venueId;

  const VenueFetchDetailRequested(this.venueId);

  @override
  List<Object> get props => [venueId];
}
