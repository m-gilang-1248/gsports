import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/get_my_bookings.dart';
import 'package:injectable/injectable.dart';

part 'history_event.dart';
part 'history_state.dart';

@injectable
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final GetMyBookings getMyBookings;

  HistoryBloc({required this.getMyBookings}) : super(HistoryInitial()) {
    on<FetchBookingHistory>(_onFetchHistory);
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
}
