part of 'venue_bloc.dart';

abstract class VenueState extends Equatable {
  const VenueState();

  @override
  List<Object> get props => [];
}

class VenueInitial extends VenueState {}

class VenueListLoading extends VenueState {}

class VenueDetailLoading extends VenueState {}

// Deprecated: Kept for backward compatibility if needed, but we should migrate.
// class VenueLoading extends VenueState {}

class VenueListLoaded extends VenueState {
  final List<Venue> allVenues;
  final List<Venue> filteredVenues;
  final List<String> availableCities;
  final String? selectedCity;
  final double? userLat;
  final double? userLng;

  const VenueListLoaded({
    required this.allVenues,
    required this.filteredVenues,
    required this.availableCities,
    this.selectedCity,
    this.userLat,
    this.userLng,
  });

  @override
  List<Object> get props => [
    allVenues,
    filteredVenues,
    availableCities,
    selectedCity ?? '',
    userLat ?? 0.0,
    userLng ?? 0.0,
  ];

  VenueListLoaded copyWith({
    List<Venue>? allVenues,
    List<Venue>? filteredVenues,
    List<String>? availableCities,
    String? selectedCity,
    double? userLat,
    double? userLng,
  }) {
    return VenueListLoaded(
      allVenues: allVenues ?? this.allVenues,
      filteredVenues: filteredVenues ?? this.filteredVenues,
      availableCities: availableCities ?? this.availableCities,
      selectedCity: selectedCity ?? this.selectedCity,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
    );
  }
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
