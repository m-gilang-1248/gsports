import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart'; // Added
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

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
       super(HistoryInitial()) {
    on<FetchBookingHistory>(_onFetchHistory);
    on<JoinBookingRequested>(_onJoinBookingRequested);
  }

  Future<void> _onFetchHistory(
    FetchBookingHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading());
    final result = await getMyBookings(event.userId);
    await result.fold((failure) async => emit(HistoryError(failure.message)), (
      bookings,
    ) async {
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

      emit(HistoryLoaded(updatedBookings));
    });
  }

  Future<void> _onJoinBookingRequested(
    JoinBookingRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(HistoryLoading()); // Indicate loading while joining

    // Get current user details to create PaymentParticipant using injected FirebaseAuth
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      emit(const HistoryError('User not logged in.'));
      add(FetchBookingHistory(event.userId)); // Revert to previous state
      return;
    }

    final participant = PaymentParticipant(
      uid: currentUser.uid,
      name: currentUser.displayName ?? 'Guest', // Fallback name
      status: 'joined',
      paymentStatusToHost: 'pending',
      profileUrl: currentUser.photoURL,
    );

    final result = await _joinBooking(event.splitCode, participant);
    result.fold((failure) => emit(HistoryError(failure.message)), (bookingId) {
      emit(HistoryJoinSuccess(bookingId));
      add(FetchBookingHistory(event.userId)); // Refresh history on success
    });
  }
}
