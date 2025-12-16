import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/generate_split_code.dart';
import 'package:gsports/features/booking/domain/usecases/get_booking_detail.dart';
import 'package:gsports/features/booking/domain/usecases/update_participant_status.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

@injectable
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final GetBookingDetail _getBookingDetail;
  final GenerateSplitCode _generateSplitCode;
  final UpdateParticipantStatus _updateParticipantStatus;

  BookingDetailBloc(
    this._getBookingDetail,
    this._generateSplitCode,
    this._updateParticipantStatus,
  ) : super(BookingDetailInitial()) {
    on<FetchBookingDetail>(_onFetchBookingDetail);
    on<GenerateCodeRequested>(_onGenerateCodeRequested);
    on<UpdateParticipantPaymentStatus>(_onUpdateParticipantPaymentStatus);
  }

  Future<void> _onFetchBookingDetail(
    FetchBookingDetail event,
    Emitter<BookingDetailState> emit,
  ) async {
    emit(BookingDetailLoading());
    final result = await _getBookingDetail(event.bookingId);
    result.fold(
      (failure) => emit(BookingDetailError(_mapFailureToMessage(failure))),
      (booking) => emit(BookingDetailLoaded(booking)),
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
