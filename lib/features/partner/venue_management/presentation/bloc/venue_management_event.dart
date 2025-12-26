part of 'venue_management_bloc.dart';

abstract class VenueManagementEvent extends Equatable {
  const VenueManagementEvent();

  @override
  List<Object?> get props => [];
}

class FetchMyVenues extends VenueManagementEvent {}

class CreateVenueRequested extends VenueManagementEvent {
  final Venue venue;
  final List<File> images;

  const CreateVenueRequested(this.venue, this.images);

  @override
  List<Object?> get props => [venue, images];
}

class UpdateVenueRequested extends VenueManagementEvent {
  final Venue venue;
  final List<File>? newImages;
  final List<String>? removedImageUrls;

  const UpdateVenueRequested(
    this.venue, {
    this.newImages,
    this.removedImageUrls,
  });

  @override
  List<Object?> get props => [venue, newImages, removedImageUrls];
}

class DeleteVenueRequested extends VenueManagementEvent {
  final String venueId;

  const DeleteVenueRequested(this.venueId);

  @override
  List<Object?> get props => [venueId];
}
