part of 'venue_management_bloc.dart';

abstract class VenueManagementState extends Equatable {
  const VenueManagementState();

  @override
  List<Object?> get props => [];
}

class VenueManagementInitial extends VenueManagementState {}

class VenueManagementLoading extends VenueManagementState {}

class VenueManagementSuccess extends VenueManagementState {
  final List<Venue> venues;
  final String? message;

  const VenueManagementSuccess(this.venues, {this.message});

  @override
  List<Object?> get props => [venues, message];
}

class VenueActionSuccess extends VenueManagementState {
  final String message;

  const VenueActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class VenueManagementError extends VenueManagementState {
  final String message;

  const VenueManagementError(this.message);

  @override
  List<Object?> get props => [message];
}
