import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_partner_bookings.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart'; // Added

part 'order_management_event.dart';
part 'order_management_state.dart';

@injectable
class OrderManagementBloc
    extends Bloc<OrderManagementEvent, OrderManagementState> {
  final GetPartnerBookings getPartnerBookings;
  final CancelBooking _cancelBooking; // Added CancelBooking
  StreamSubscription? _bookingsSubscription;

  OrderManagementBloc(this.getPartnerBookings, this._cancelBooking)
    : super(OrderManagementInitial()) {
    on<FetchPartnerBookings>(_onFetchPartnerBookings);
    on<PartnerBookingsUpdated>(_onPartnerBookingsUpdated);
    on<UpdateCalendarFocusedDay>(_onUpdateCalendarFocusedDay);
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

    await _bookingsSubscription?.cancel();
    _bookingsSubscription = getPartnerBookings.callStream(user.uid).listen((
      result,
    ) {
      result.fold(
        (failure) => add(PartnerBookingsUpdated(const [])), // Or handle error
        (bookings) => add(PartnerBookingsUpdated(bookings)),
      );
    });
  }

  void _onPartnerBookingsUpdated(
    PartnerBookingsUpdated event,
    Emitter<OrderManagementState> emit,
  ) {
    final bookings = event.bookings;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 1. Filter and Check for Expiry
    final validBookings = <Booking>[];
    for (final booking in bookings) {
      if (booking.status == 'waiting_payment') {
        final difference = now.difference(booking.createdAt);
        if (difference.inMinutes >= 15) {
          // Auto-cancel in background
          _cancelBooking(booking.id);
          // Don't add to validBookings for current state emission
          continue;
        }
      }
      validBookings.add(booking);
    }

    // 2. Pending Bookings (Status: waiting_payment)
    final pending = validBookings
        .where((b) => b.status == 'waiting_payment')
        .toList();
    // Sort pending by oldest first (urgent to confirm) or newest? usually newest first for dashboard
    pending.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    // 3. Upcoming Bookings (Status: paid AND date >= today)
    final upcoming = validBookings.where((b) {
      final isPaid = b.status == 'paid';
      final bookingDate = DateTime(b.date.year, b.date.month, b.date.day);
      return isPaid && !bookingDate.isBefore(today);
    }).toList();
    // Sort Ascending (Nearest date first)
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

    // 4. History Bookings (Status: completed, cancelled OR date < today)
    final history = validBookings.where((b) {
      final isFinishedStatus =
          b.status == 'completed' || b.status == 'cancelled';
      final bookingDate = DateTime(b.date.year, b.date.month, b.date.day);
      final isPastDate = bookingDate.isBefore(today) && b.status == 'paid';

      return isFinishedStatus || isPastDate;
    }).toList();
    // Sort Descending (Newest date first)
    history.sort((a, b) => b.startTime.compareTo(a.startTime));

    // 5. Map for Calendar
    final bookingsByDate = <DateTime, List<Booking>>{};
    for (var booking in validBookings) {
      // Normalize date to 00:00:00
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

    // Preserve focused/selected day if already loaded
    DateTime focusedDay = now;
    DateTime? selectedDay = now;

    if (state is OrderManagementLoaded) {
      final currentState = state as OrderManagementLoaded;
      focusedDay = currentState.focusedDay;
      selectedDay = currentState.selectedDay;
    }

    emit(
      OrderManagementLoaded(
        allBookings: validBookings,
        pendingBookings: pending,
        upcomingBookings: upcoming,
        historyBookings: history,
        bookingsByDate: bookingsByDate,
        focusedDay: focusedDay,
        selectedDay: selectedDay,
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
