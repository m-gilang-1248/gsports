import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/check_availability.dart';
import 'package:gsports/features/booking/domain/usecases/create_booking.dart';

part 'booking_event.dart';
part 'booking_state.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CheckAvailability checkAvailability;
  final CreateBooking createBooking;

  BookingBloc({required this.checkAvailability, required this.createBooking})
    : super(BookingInitial()) {
    on<BookingAvailabilityChecked>(_onAvailabilityChecked);
    on<BookingSlotSelected>(_onSlotSelected);
    on<BookingCreated>(_onCreated);
  }

  Future<void> _onAvailabilityChecked(
    BookingAvailabilityChecked event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final availabilityMap = <int, bool>{};
    final date = event.date;
    final courtId = event.courtId;

    // Check hours 08:00 to 22:00 (inclusive start)
    // Optimizing: In a real app, we'd fetch all bookings once.
    // Here we loop UseCase calls as per design decision for MVP simplicity.
    // Parallelizing requests for speed.

    final futures = <Future<void>>[];

    for (int hour = 8; hour <= 22; hour++) {
      futures.add(() async {
        final startTime = DateTime(date.year, date.month, date.day, hour);
        final endTime = startTime.add(const Duration(hours: 1));

        final result = await checkAvailability(
          CheckAvailabilityParams(
            courtId: courtId,
            date: date,
            startTime: startTime,
            endTime: endTime,
          ),
        );

        result.fold(
          (failure) =>
              availabilityMap[hour] = false, // Treat error as unavailable
          (isAvailable) => availabilityMap[hour] = isAvailable,
        );
      }());
    }

    await Future.wait(futures);

    emit(
      BookingAvailabilityLoaded(
        availabilityMap: availabilityMap,
        selectedCourtId: courtId,
        selectedDate: date,
        selectedStartTime: null, // Reset selection on new check
      ),
    );
  }

  void _onSlotSelected(BookingSlotSelected event, Emitter<BookingState> emit) {
    if (state is BookingAvailabilityLoaded) {
      final currentState = state as BookingAvailabilityLoaded;
      emit(currentState.copyWith(selectedStartTime: event.startTime));
    }
  }

  Future<void> _onCreated(
    BookingCreated event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await createBooking(
      CreateBookingParams(booking: event.booking),
    );
    result.fold(
      (failure) => emit(BookingFailure(failure.message)),
      (bookingId) => emit(BookingSuccess(bookingId)),
    );
  }
}
