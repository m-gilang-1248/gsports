import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart'; // Added
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth
import 'package:gsports/core/constants/filter_constants.dart';

part 'history_event.dart';
part 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyBookings getMyBookings;
  final JoinBooking _joinBooking;
  final CancelBooking _cancelBooking; // Added CancelBooking
  final FirebaseAuth _firebaseAuth;

  HistoryBloc({
    required this.getMyBookings,
    required JoinBooking joinBooking,
    required CancelBooking cancelBooking, // Added to constructor
    required FirebaseAuth firebaseAuth,
  }) : _joinBooking = joinBooking,
       _cancelBooking = cancelBooking,
       _firebaseAuth = firebaseAuth,
       super(const HistoryState()) {
    on<FetchBookingHistory>(_onFetchHistory);
    on<JoinBookingRequested>(_onJoinBookingRequested);
    on<UpdateBookingSportFilter>(_onUpdateSportFilter);
    on<UpdateBookingTimeFilter>(_onUpdateTimeFilter);
  }

  Future<void> _onFetchHistory(
    FetchBookingHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));
    final result = await getMyBookings(event.userId);
    await result.fold(
      (failure) async => emit(
        state.copyWith(status: HistoryStatus.error, message: failure.message),
      ),
      (bookings) async {
        final now = DateTime.now();
        final updatedBookings = List<Booking>.from(bookings);

        for (int i = 0; i < updatedBookings.length; i++) {
          final booking = updatedBookings[i];
          if (booking.status == 'waiting_payment') {
            final difference = now.difference(booking.createdAt);
            if (difference.inMinutes >= 15) {
              // Auto-cancel in database
              await _cancelBooking(booking.id);

              // Update local state
              updatedBookings[i] = Booking(
                id: booking.id,
                userId: booking.userId,
                venueId: booking.venueId,
                ownerId: booking.ownerId,
                courtId: booking.courtId,
                sportType: booking.sportType,
                date: booking.date,
                startTime: booking.startTime,
                endTime: booking.endTime,
                durationHours: booking.durationHours,
                totalPrice: booking.totalPrice,
                status: 'cancelled', // Changed locally
                paymentStatus: booking.paymentStatus,
                venueName: booking.venueName,
                courtName: booking.courtName,
                venueLocation: booking.venueLocation,
                midtransOrderId: booking.midtransOrderId,
                midtransPaymentUrl: booking.midtransPaymentUrl,
                isSplitBill: booking.isSplitBill,
                splitCode: booking.splitCode,
                participants: booking.participants,
                participantIds: booking.participantIds,
                createdAt: booking.createdAt,
              );
            }
          }
        }

        final filtered = _applyFilters(
          updatedBookings,
          state.selectedSportId,
          state.selectedTimePreset,
          state.customDate,
        );

        emit(
          state.copyWith(
            status: HistoryStatus.loaded,
            bookings: updatedBookings,
            filteredHistoryBookings: filtered,
          ),
        );
      },
    );
  }

  void _onUpdateSportFilter(
    UpdateBookingSportFilter event,
    Emitter<HistoryState> emit,
  ) {
    final filtered = _applyFilters(
      state.bookings,
      event.sportId,
      state.selectedTimePreset,
      state.customDate,
    );
    emit(
      state.copyWith(
        selectedSportId: event.sportId,
        clearSportId: event.sportId == null,
        filteredHistoryBookings: filtered,
      ),
    );
  }

  void _onUpdateTimeFilter(
    UpdateBookingTimeFilter event,
    Emitter<HistoryState> emit,
  ) {
    final filtered = _applyFilters(
      state.bookings,
      state.selectedSportId,
      event.preset,
      event.customDate,
    );
    emit(
      state.copyWith(
        selectedTimePreset: event.preset,
        customDate: event.customDate,
        filteredHistoryBookings: filtered,
      ),
    );
  }

  List<Booking> _applyFilters(
    List<Booking> bookings,
    String? sportId,
    TimeFilterPreset timePreset,
    DateTime? customDate,
  ) {
    final now = DateTime.now();

    // 1. Identify History Bookings (Logic from BookingHistoryPage)
    final history = bookings.where((b) {
      final isCancelled = b.status == 'cancelled' || b.status == 'expired';
      final isPaidFinished =
          (b.status == 'confirmed' || b.status == 'paid') &&
          (b.endTime.isBefore(now) || b.endTime.isAtSameMomentAs(now));
      return isCancelled || isPaidFinished;
    }).toList();

    // 2. Apply Dynamic Filters
    return history.where((b) {
      // Sport Filter
      if (sportId != null &&
          b.sportType.toLowerCase() != sportId.toLowerCase()) {
        return false;
      }

      // Time Filter
      final today = DateTime(now.year, now.month, now.day);
      switch (timePreset) {
        case TimeFilterPreset.all:
          return true;
        case TimeFilterPreset.thisWeek:
          final weekAgo = today.subtract(const Duration(days: 7));
          return b.date.isAfter(weekAgo);
        case TimeFilterPreset.thisMonth:
          final monthAgo = DateTime(today.year, today.month - 1, today.day);
          return b.date.isAfter(monthAgo);
        case TimeFilterPreset.customDate:
          if (customDate == null) return true;
          return b.date.year == customDate.year &&
              b.date.month == customDate.month &&
              b.date.day == customDate.day;
      }
    }).toList()..sort((a, b) => b.date.compareTo(a.date)); // Terbaru atas
  }

  Future<void> _onJoinBookingRequested(
    JoinBookingRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading));

    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(
        state.copyWith(
          status: HistoryStatus.error,
          message: 'User not logged in.',
        ),
      );
      add(FetchBookingHistory(event.userId));
      return;
    }

    final participant = PaymentParticipant(
      uid: currentUser.uid,
      name: currentUser.displayName ?? 'Guest',
      status: 'joined',
      paymentStatusToHost: 'pending',
      profileUrl: currentUser.photoURL,
    );

    final result = await _joinBooking(event.splitCode, participant);
    result.fold(
      (failure) => emit(
        state.copyWith(status: HistoryStatus.error, message: failure.message),
      ),
      (bookingId) {
        emit(
          state.copyWith(
            status: HistoryStatus.joinSuccess,
            bookingId: bookingId,
          ),
        );
        add(FetchBookingHistory(event.userId));
      },
    );
  }
}
