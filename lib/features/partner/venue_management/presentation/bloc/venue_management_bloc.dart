import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/get_my_venues.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/create_venue.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/update_venue.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/delete_venue.dart';

part 'venue_management_event.dart';
part 'venue_management_state.dart';

@injectable
class VenueManagementBloc
    extends Bloc<VenueManagementEvent, VenueManagementState> {
  final GetMyVenues getMyVenues;
  final CreateVenue createVenue;
  final UpdateVenue updateVenue;
  final DeleteVenue deleteVenue;
  final FirebaseAuth firebaseAuth;

  VenueManagementBloc({
    required this.getMyVenues,
    required this.createVenue,
    required this.updateVenue,
    required this.deleteVenue,
    required this.firebaseAuth,
  }) : super(VenueManagementInitial()) {
    on<FetchMyVenues>(_onFetchMyVenues);
    on<CreateVenueRequested>(_onCreateVenue);
    on<UpdateVenueRequested>(_onUpdateVenue);
    on<DeleteVenueRequested>(_onDeleteVenue);
  }

  Future<void> _onFetchMyVenues(
    FetchMyVenues event,
    Emitter<VenueManagementState> emit,
  ) async {
    emit(VenueManagementLoading());
    final user = firebaseAuth.currentUser;
    if (user == null) {
      emit(const VenueManagementError("User not logged in"));
      return;
    }

    final result = await getMyVenues(user.uid);
    result.fold(
      (failure) => emit(VenueManagementError(failure.message)),
      (venues) => emit(VenueManagementSuccess(venues)),
    );
  }

  Future<void> _onCreateVenue(
    CreateVenueRequested event,
    Emitter<VenueManagementState> emit,
  ) async {
    emit(VenueManagementLoading());
    final result = await createVenue(event.venue, event.images);
    result.fold(
      (failure) => emit(VenueManagementError(failure.message)),
      (_) => emit(const VenueActionSuccess("Venue created successfully")),
    );
  }

  Future<void> _onUpdateVenue(
    UpdateVenueRequested event,
    Emitter<VenueManagementState> emit,
  ) async {
    emit(VenueManagementLoading());
    final result = await updateVenue(
      event.venue,
      newImages: event.newImages,
      removedImageUrls: event.removedImageUrls,
    );
    result.fold(
      (failure) => emit(VenueManagementError(failure.message)),
      (_) => emit(const VenueActionSuccess("Venue updated successfully")),
    );
  }

  Future<void> _onDeleteVenue(
    DeleteVenueRequested event,
    Emitter<VenueManagementState> emit,
  ) async {
    emit(VenueManagementLoading());
    final result = await deleteVenue(event.venueId);
    result.fold(
      (failure) => emit(VenueManagementError(failure.message)),
      (_) => emit(const VenueActionSuccess("Venue deleted successfully")),
    );
  }
}
