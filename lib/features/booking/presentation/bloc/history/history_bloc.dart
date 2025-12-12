import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/booking/domain/usecases/join_booking.dart';
import 'package:gsports/features/booking/domain/entities/payment_participant.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

part 'history_event.dart';
part 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyBookings getMyBookings;
  final JoinBooking _joinBooking;
  final FirebaseAuth _firebaseAuth; // Added FirebaseAuth dependency

  HistoryBloc({
    required this.getMyBookings,
    required JoinBooking joinBooking,
    required FirebaseAuth firebaseAuth, // Added to constructor
  }) : _joinBooking = joinBooking,
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
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (bookings) => emit(HistoryLoaded(bookings)),
    );
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
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) =>
          add(FetchBookingHistory(event.userId)), // Refresh history on success
    );
  }
}
