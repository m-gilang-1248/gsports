part of 'venue_bloc.dart';

abstract class VenueState extends Equatable {
  const VenueState();

  @override
  List<Object> get props => [];
}

class VenueInitial extends VenueState {}

class VenueLoading extends VenueState {}

class VenueListLoaded extends VenueState {
  final List<Venue> venues;

  const VenueListLoaded(this.venues);

  @override
  List<Object> get props => [venues];
}

class VenueDetailLoaded extends VenueState {
  final Venue venue;
  final List<Court> courts;

  const VenueDetailLoaded({required this.venue, required this.courts});

  @override
  List<Object> get props => [venue, courts];
}

class VenueError extends VenueState {
  final String message;

  const VenueError(this.message);

  @override
  List<Object> get props => [message];
}
