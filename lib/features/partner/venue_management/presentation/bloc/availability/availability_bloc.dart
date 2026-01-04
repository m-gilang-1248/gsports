import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/get_my_venues.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/manage_courts_usecases.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/get_maintenance_bookings.dart';

part 'availability_event.dart';
part 'availability_state.dart';

@injectable
class AvailabilityBloc extends Bloc<AvailabilityEvent, AvailabilityState> {
  final GetMyVenues getMyVenues;
  final GetManagedVenueCourts getVenueCourts;
  final GetMaintenanceBookings getMaintenanceBookings;
  final FirebaseAuth firebaseAuth;

  AvailabilityBloc({
    required this.getMyVenues,
    required this.getVenueCourts,
    required this.getMaintenanceBookings,
    required this.firebaseAuth,
  }) : super(AvailabilityInitial()) {
    on<AvailabilityInit>(_onInit);
    on<AvailabilityVenueSelected>(_onVenueSelected);
    on<AvailabilityCourtSelected>(_onCourtSelected);
    on<AvailabilityMonthChanged>(_onMonthChanged);
  }

  Future<void> _onInit(
    AvailabilityInit event,
    Emitter<AvailabilityState> emit,
  ) async {
    emit(AvailabilityLoading());
    final user = firebaseAuth.currentUser;
    if (user == null) {
      emit(const AvailabilityError("User not logged in"));
      return;
    }

    final result = await getMyVenues(user.uid);
    await result.fold(
      (failure) async => emit(AvailabilityError(failure.message)),
      (venues) async {
        if (venues.isEmpty) {
          emit(AvailabilityLoaded(focusedDay: DateTime.now()));
          return;
        }
        final initialVenue = venues.first;
        final courtsResult = await getVenueCourts(initialVenue.id);

        courtsResult.fold(
          (failure) => emit(AvailabilityError(failure.message)),
          (courts) {
            // Initial load of maintenance for current month
            add(AvailabilityMonthChanged(DateTime.now()));
            emit(
              AvailabilityLoaded(
                venues: venues,
                selectedVenue: initialVenue,
                courts: courts,
                focusedDay: DateTime.now(),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onVenueSelected(
    AvailabilityVenueSelected event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is AvailabilityLoaded) {
      emit(AvailabilityLoading());

      final courtsResult = await getVenueCourts(event.venue.id);

      courtsResult.fold((failure) => emit(AvailabilityError(failure.message)), (
        courts,
      ) {
        emit(
          currentState.copyWith(
            selectedVenue: event.venue,
            courts: courts,
            clearSelectedCourt: true,
            maintenanceBookings: [], // Clear old maintenance
          ),
        );
        add(AvailabilityMonthChanged(currentState.focusedDay));
      });
    }
  }

  Future<void> _onCourtSelected(
    AvailabilityCourtSelected event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is AvailabilityLoaded) {
      emit(
        currentState.copyWith(
          selectedCourt: event.court,
          // Hack: Force null if event.court is null
          clearSelectedCourt: event.court == null,
        ),
      );
    }
  }

  Future<void> _onMonthChanged(
    AvailabilityMonthChanged event,
    Emitter<AvailabilityState> emit,
  ) async {
    final currentState = state;
    if (currentState is AvailabilityLoaded &&
        currentState.selectedVenue != null) {
      // Fetch maintenance for the whole month (start - end)
      // We take some buffer (previous and next month to be safe for calendar scrolling)
      final start = DateTime(
        event.focusedDay.year,
        event.focusedDay.month - 1,
        1,
      );
      final end = DateTime(
        event.focusedDay.year,
        event.focusedDay.month + 2,
        0,
      );

      final result = await getMaintenanceBookings(
        currentState.selectedVenue!.id,
        start,
        end,
      );

      result.fold(
        (failure) => emit(AvailabilityError(failure.message)),
        (bookings) => emit(
          currentState.copyWith(
            maintenanceBookings: bookings,
            focusedDay: event.focusedDay,
          ),
        ),
      );
    }
  }
}
