import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/generate_split_code.dart';
import 'package:gsports/features/booking/domain/usecases/get_booking_detail.dart';

part 'booking_detail_event.dart';
part 'booking_detail_state.dart';

@injectable
class BookingDetailBloc extends Bloc<BookingDetailEvent, BookingDetailState> {
  final GetBookingDetail _getBookingDetail;
  final GenerateSplitCode _generateSplitCode;

  BookingDetailBloc(this._getBookingDetail, this._generateSplitCode)
    : super(BookingDetailInitial()) {
    on<FetchBookingDetail>(_onFetchBookingDetail);
    on<GenerateCodeRequested>(_onGenerateCodeRequested);
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

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return (failure as ServerFailure).message ?? 'Server Error';
      case CacheFailure:
        return (failure as CacheFailure).message ?? 'Cache Error';
      default:
        return 'Unexpected Error';
    }
  }
}
