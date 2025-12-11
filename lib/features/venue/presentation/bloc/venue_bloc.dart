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
  }

  Future<void> _onFetchList(
    VenueFetchListRequested event,
    Emitter<VenueState> emit,
  ) async {
    emit(VenueListLoading());
    final result = await getVenues(NoParams());
    result.fold(
      (failure) => emit(VenueError(failure.message)),
      (venues) => emit(VenueListLoaded(venues)),
    );
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
