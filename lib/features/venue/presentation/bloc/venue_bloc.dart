import 'dart:math' show cos, sqrt, asin;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/usecases/get_venues.dart';
import 'package:gsports/features/venue/domain/usecases/get_venue_detail.dart';
import 'package:gsports/features/venue/domain/usecases/get_venue_courts.dart';

part 'venue_event.dart';
part 'venue_state.dart';

@injectable
class VenueBloc extends Bloc<VenueEvent, VenueState> {
  final GetVenues getVenues;
  final GetVenueDetail getVenueDetail;
  final GetVenueCourts getVenueCourts;

  VenueBloc({
    required this.getVenues,
    required this.getVenueDetail,
    required this.getVenueCourts,
  }) : super(VenueInitial()) {
    on<VenueFetchListRequested>(_onFetchList);
    on<VenueFetchDetailRequested>(_onFetchDetail);
    on<VenueSearchRequested>(_onSearch);
    on<VenueLocationDetected>(_onLocationDetected);
  }

  Future<void> _onFetchList(
    VenueFetchListRequested event,
    Emitter<VenueState> emit,
  ) async {
    emit(VenueListLoading());
    final result = await getVenues(NoParams());
    result.fold((failure) => emit(VenueError(failure.message)), (venues) {
      final cities = venues
          .map((v) => v.city)
          .whereType<String>()
          .toSet()
          .toList();
      cities.sort();
      emit(
        VenueListLoaded(
          allVenues: venues,
          filteredVenues: venues,
          availableCities: cities,
        ),
      );
    });
  }

  void _onSearch(VenueSearchRequested event, Emitter<VenueState> emit) {
    if (state is VenueListLoaded) {
      final currentState = state as VenueListLoaded;
      final query = event.query.toLowerCase();

      final filtered = currentState.allVenues.where((venue) {
        final matchesQuery =
            venue.name.toLowerCase().contains(query) ||
            (venue.address.toLowerCase().contains(query));

        final matchesSport =
            event.sportType == null ||
            venue.sportCategories.contains(event.sportType);

        final matchesCity = event.city == null || venue.city == event.city;

        final matchesFacilities =
            event.facilities == null ||
            event.facilities!.every((f) => venue.facilities.contains(f));

        return matchesQuery && matchesSport && matchesCity && matchesFacilities;
      }).toList();

      // If user has location, sort by distance after filtering
      if (currentState.userLat != null && currentState.userLng != null) {
        filtered.sort((a, b) {
          final distA = _calculateDistance(
            currentState.userLat!,
            currentState.userLng!,
            a.location.lat,
            a.location.lng,
          );
          final distB = _calculateDistance(
            currentState.userLat!,
            currentState.userLng!,
            b.location.lat,
            b.location.lng,
          );
          return distA.compareTo(distB);
        });
      }

      emit(
        currentState.copyWith(
          filteredVenues: filtered,
          selectedCity: event.city,
        ),
      );
    }
  }

  void _onLocationDetected(
    VenueLocationDetected event,
    Emitter<VenueState> emit,
  ) {
    if (state is VenueListLoaded) {
      final currentState = state as VenueListLoaded;

      // Only filter by city if the detected city exists in our database
      String? matchedCity;
      if (event.cityName != null &&
          currentState.availableCities.contains(event.cityName)) {
        matchedCity = event.cityName;
      }

      List<Venue> filtered = currentState.allVenues;
      if (matchedCity != null) {
        filtered = currentState.allVenues
            .where((v) => v.city == matchedCity)
            .toList();
      }

      // Sort by proximity (always do this if location is detected)
      filtered.sort((a, b) {
        final distA = _calculateDistance(
          event.lat,
          event.lng,
          a.location.lat,
          a.location.lng,
        );
        final distB = _calculateDistance(
          event.lat,
          event.lng,
          b.location.lat,
          b.location.lng,
        );
        return distA.compareTo(distB);
      });

      emit(
        currentState.copyWith(
          filteredVenues: filtered,
          selectedCity: matchedCity,
          userLat: event.lat,
          userLng: event.lng,
        ),
      );
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }

  Future<void> _onFetchDetail(
    VenueFetchDetailRequested event,
    Emitter<VenueState> emit,
  ) async {
    emit(VenueDetailLoading());
    // Fetch venue detail and courts in parallel
    final results = await Future.wait([
      getVenueDetail(GetVenueDetailParams(venueId: event.venueId)),
      getVenueCourts(GetVenueCourtsParams(venueId: event.venueId)),
    ]);

    final detailResult = results[0] as dynamic; // Either<Failure, Venue>
    final courtsResult = results[1] as dynamic; // Either<Failure, List<Court>>

    // Check if venue detail failed
    if (detailResult.isLeft()) {
      detailResult.fold(
        (failure) => emit(VenueError(failure.message)),
        (_) {}, // Should not happen
      );
      return;
    }

    // Check if courts failed (optional: we might show venue even if courts fail, but for now let's fail)
    if (courtsResult.isLeft()) {
      courtsResult.fold((failure) => emit(VenueError(failure.message)), (_) {});
      return;
    }

    // If both success
    final venue = detailResult.getRight().toNullable() as Venue;
    final courts = courtsResult.getRight().toNullable() as List<Court>;

    emit(VenueDetailLoaded(venue: venue, courts: courts));
  }
}
