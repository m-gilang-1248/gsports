import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/domain/usecases/generate_split_code.dart';
import 'package:gsports/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:gsports/features/booking/domain/usecases/update_participant_status.dart';

import 'package:gsports/features/payment/domain/usecases/get_transaction_status.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

@injectable
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final GetBookingDetail _getBookingDetail;
  final GenerateSplitCode _generateSplitCode;
  final UpdateParticipantStatus _updateParticipantStatus;
  final CancelBooking _cancelBooking;
  final GetTransactionStatus _getTransactionStatus;
  final UpdateBookingStatus _updateBookingStatus;
  final ScoreboardRepository _scoreboardRepository;

  BookingDetailBloc(
    this._getBookingDetail,
    this._generateSplitCode,
    this._updateParticipantStatus,
    this._cancelBooking,
    this._getTransactionStatus,
    this._updateBookingStatus,
    this._scoreboardRepository,
  ) : super(BookingDetailInitial()) {
    on<FetchBookingDetail>(_onFetchBookingDetail);
    on<GenerateCodeRequested>(_onGenerateCodeRequested);
    on<UpdateParticipantPaymentStatus>(_onUpdateParticipantPaymentStatus);
    on<CancelBookingRequested>(_onCancelBookingRequested);
    on<SyncBookingStatus>(_onSyncBookingStatus);
  }

  Future<void> _onSyncBookingStatus(
    SyncBookingStatus event,
    Emitter<BookingDetailState> emit,
  ) async {
    // 1. Get transaction status from Midtrans
    final statusResult = await _getTransactionStatus(event.bookingId);

    await statusResult.fold(
      (failure) async => emit(BookingDetailError(failure.message)),
      (midtransStatus) async {
        String? newStatus;
        if (midtransStatus == 'settlement' || midtransStatus == 'capture') {
          newStatus = 'paid';
        } else if (midtransStatus == 'expire' ||
            midtransStatus == 'cancel' ||
            midtransStatus == 'deny') {
          newStatus = 'cancelled';
        }

        if (newStatus != null) {
          // 2. Update Firestore if status changed
          await _updateBookingStatus(
            UpdateBookingStatusParams(
              bookingId: event.bookingId,
              status: newStatus,
            ),
          );
        }

        // 3. Refresh data from Firestore
        add(FetchBookingDetail(event.bookingId));
      },
    );
  }

  Future<void> _onFetchBookingDetail(
    FetchBookingDetail event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(BookingDetailLoading());
    final result = await _getBookingDetail(event.bookingId);
    final matchesResult =
        await _scoreboardRepository.getMatchesByBooking(event.bookingId);

    result.fold(
      (failure) => emit(BookingDetailError(_mapFailureToMessage(failure))),
      (booking) {
        matchesResult.fold(
          (failure) => emit(BookingDetailLoaded(booking)), // Load without matches if error
          (matches) => emit(BookingDetailLoaded(booking, matches: matches)),
        );
      },
    );
  }

  Future<void> _onGenerateCodeRequested(
    GenerateCodeRequested event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(BookingDetailLoading());
    final result = await _generateSplitCode(event.bookingId);
    result.fold(
      (failure) => emit(BookingDetailError(_mapFailureToMessage(failure))),
      (_) =>
          add(FetchBookingDetail(event.bookingId)), // Refresh booking details
    );
  }

  Future<void> _onCancelBookingRequested(
    CancelBookingRequested event,
    Emitter<BookingDetailState> emit,
  ) async {
    // Optimistically update UI or show loading?
    // For now, let's just call the usecase and refresh.
    final result = await _cancelBooking(event.bookingId);
    result.fold(
      (failure) => emit(BookingDetailError(_mapFailureToMessage(failure))),
      (_) => add(FetchBookingDetail(event.bookingId)),
    );
  }

  Future<void> _onUpdateParticipantPaymentStatus(
    UpdateParticipantPaymentStatus event,
    Emitter<BookingDetailState> emit,
  ) async {
    // Current state should be loaded for us to update participant status
    if (state is! BookingDetailLoaded) {
      return;
    }

    // Temporarily emit loading to show UI feedback, but preserve current data
    emit(
      BookingDetailLoaded(
        (state as BookingDetailLoaded).booking,
        isUpdatingParticipant: true,
      ),
    );

    final result = await _updateParticipantStatus(
      bookingId: event.bookingId,
      participantUid: event.participantUid,
      newStatus: event.newStatus,
    );

    await result.fold(
      (failure) async =>
          emit(BookingDetailError(_mapFailureToMessage(failure))),
      (_) async =>
          add(FetchBookingDetail(event.bookingId)), // Refresh booking details
    );
  }

  String _mapFailureToMessage(Failure failure) {
    return failure.message;
  }
}
