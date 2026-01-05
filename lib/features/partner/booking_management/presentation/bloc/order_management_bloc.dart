import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_partner_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/partner/venue_management/domain/usecases/get_my_venues.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

part 'order_management_event.dart';
part 'order_management_state.dart';

@injectable
class OrderManagementBloc
    extends Bloc<OrderManagementEvent, OrderManagementState> {
  final GetPartnerBookings getPartnerBookings;
  final CancelBooking _cancelBooking;
  final GetMyVenues getMyVenues;
  StreamSubscription? _bookingsSubscription;

  OrderManagementBloc(
    this.getPartnerBookings,
    this._cancelBooking,
    this.getMyVenues,
  ) : super(OrderManagementInitial()) {
    on<FetchPartnerBookings>(_onFetchPartnerBookings);
    on<PartnerBookingsUpdated>(_onPartnerBookingsUpdated);
    on<UpdateCalendarFocusedDay>(_onUpdateCalendarFocusedDay);
    on<OrderManagementFilterChanged>(_onFilterChanged);
  }

  @override
  Future<void> close() {
    _bookingsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onFetchPartnerBookings(
    FetchPartnerBookings event,
    Emitter<OrderManagementState> emit,
  ) async {
    emit(OrderManagementLoading());

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(const OrderManagementFailure('User not authenticated'));
      return;
    }

    // Fetch Venues (Inventory)
    final venuesResult = await getMyVenues(user.uid);
    final venues = venuesResult.fold((_) => const <Venue>[], (v) => v);

    await _bookingsSubscription?.cancel();
    _bookingsSubscription = getPartnerBookings.callStream(user.uid).listen((
      result,
    ) {
      result.fold(
        (failure) => add(PartnerBookingsUpdated(const [], venues: venues)),
        (bookings) => add(PartnerBookingsUpdated(bookings, venues: venues)),
      );
    });
  }

  void _onPartnerBookingsUpdated(
    PartnerBookingsUpdated event,
    Emitter<OrderManagementState> emit,
  ) {
    _applyFiltersAndEmit(
      emit,
      allBookings: event.bookings,
      availableVenues: event.venues,
    );
  }

  void _onFilterChanged(
    OrderManagementFilterChanged event,
    Emitter<OrderManagementState> emit,
  ) {
    if (state is OrderManagementLoaded) {
      if (event.clearAll) {
        _applyFiltersAndEmit(
          emit,
          clearVenue: true,
          clearCourt: true,
          clearSport: true,
          clearStatus: true,
          clearDate: true,
        );
      } else {
        _applyFiltersAndEmit(
          emit,
          filterVenueId: event.venueId,
          filterCourtId: event.courtId,
          filterSportType: event.sportType,
          filterStatus: event.status,
          filterDateRange: event.dateRange,
          // Explicitly clear if empty string passed (sent from UI to reset specific field)
          clearVenue: event.venueId == '',
          clearCourt: event.courtId == '',
          clearSport: event.sportType == '',
          clearStatus: event.status == '',
          clearDate: event.clearDate,
        );
      }
    }
  }

  void _applyFiltersAndEmit(
    Emitter<OrderManagementState> emit, {
    List<Booking>? allBookings,
    List<Venue>? availableVenues,
    String? filterVenueId,
    String? filterCourtId,
    String? filterSportType,
    String? filterStatus,
    DateTimeRange? filterDateRange,
    bool clearVenue = false,
    bool clearCourt = false,
    bool clearSport = false,
    bool clearStatus = false,
    bool clearDate = false,
  }) {
    final currentState = state is OrderManagementLoaded
        ? state as OrderManagementLoaded
        : null;

    final bookings = allBookings ?? currentState?.allBookings ?? [];
    final venues = availableVenues ?? currentState?.availableVenues ?? [];

    // Current effective filters
    final venueId = clearVenue
        ? null
        : (filterVenueId ?? currentState?.filterVenueId);
    final courtId = clearCourt
        ? null
        : (filterCourtId ?? currentState?.filterCourtId);
    final sportType = clearSport
        ? null
        : (filterSportType ?? currentState?.filterSportType);
    final status = clearStatus
        ? null
        : (filterStatus ?? currentState?.filterStatus);
    final dateRange = clearDate
        ? null
        : (filterDateRange ?? currentState?.filterDateRange);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Filter raw bookings
    final filteredRaw = <Booking>[];
    for (final booking in bookings) {
      // Expiry Check for waiting_payment
      if (booking.status == 'waiting_payment') {
        final difference = now.difference(booking.createdAt);
        if (difference.inMinutes >= 15) {
          _cancelBooking(booking.id);
          continue;
        }
      }

      // Apply Filters
      if (venueId != null && venueId.isNotEmpty && booking.venueId != venueId) {
        continue;
      }
      if (courtId != null && courtId.isNotEmpty && booking.courtId != courtId) {
        continue;
      }
      if (sportType != null &&
          sportType.isNotEmpty &&
          booking.sportType != sportType) {
        continue;
      }
      if (status != null && status.isNotEmpty && booking.status != status) {
        continue;
      }
      if (dateRange != null) {
        final bookingDate = DateTime(
          booking.date.year,
          booking.date.month,
          booking.date.day,
        );
        final start = DateTime(
          dateRange.start.year,
          dateRange.start.month,
          dateRange.start.day,
        );
        final end = DateTime(
          dateRange.end.year,
          dateRange.end.month,
          dateRange.end.day,
        );
        if (bookingDate.isBefore(start) || bookingDate.isAfter(end)) {
          continue;
        }
      }

      filteredRaw.add(booking);
    }

    // 2. Categorize
    final pending = filteredRaw
        .where((b) => b.status == 'waiting_payment')
        .toList();
    pending.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final upcoming = filteredRaw.where((b) {
      final isPaid = b.status == 'paid';
      final bookingDate = DateTime(b.date.year, b.date.month, b.date.day);
      return isPaid && !bookingDate.isBefore(today);
    }).toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

    final history = filteredRaw.where((b) {
      final isFinishedStatus =
          b.status == 'completed' || b.status == 'cancelled';
      final bookingDate = DateTime(b.date.year, b.date.month, b.date.day);
      final isPastDate = bookingDate.isBefore(today) && b.status == 'paid';
      return isFinishedStatus || isPastDate;
    }).toList();
    history.sort((a, b) => b.startTime.compareTo(a.startTime));

    final bookingsByDate = <DateTime, List<Booking>>{};
    for (var booking in filteredRaw) {
      final normalizedDate = DateTime(
        booking.date.year,
        booking.date.month,
        booking.date.day,
      );
      if (!bookingsByDate.containsKey(normalizedDate)) {
        bookingsByDate[normalizedDate] = [];
      }
      bookingsByDate[normalizedDate]!.add(booking);
    }

    emit(
      OrderManagementLoaded(
        allBookings: bookings,
        availableVenues: venues,
        pendingBookings: pending,
        upcomingBookings: upcoming,
        historyBookings: history,
        bookingsByDate: bookingsByDate,
        focusedDay: currentState?.focusedDay ?? now,
        selectedDay: currentState?.selectedDay ?? now,
        filterVenueId: venueId,
        filterCourtId: courtId,
        filterSportType: sportType,
        filterStatus: status,
        filterDateRange: dateRange,
      ),
    );
  }

  void _onUpdateCalendarFocusedDay(
    UpdateCalendarFocusedDay event,
    Emitter<OrderManagementState> emit,
  ) {
    if (state is OrderManagementLoaded) {
      final currentState = state as OrderManagementLoaded;
      emit(
        currentState.copyWith(
          focusedDay: event.focusedDay,
          selectedDay: event.selectedDay,
        ),
      );
    }
  }
}
