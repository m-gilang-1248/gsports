import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/check_availability.dart';
import 'package:gsports/features/booking/domain/usecases/create_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/payment/domain/usecases/create_invoice.dart';
import 'package:gsports/features/payment/domain/usecases/get_transaction_status.dart';

part 'booking_event.dart';
part 'booking_state.dart';

@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final CheckAvailability checkAvailability;
  final CreateBooking createBooking;
  final CreateInvoice createInvoice;
  final CancelBooking cancelBooking;
  final UpdateBookingStatus updateBookingStatus;
  final GetTransactionStatus getTransactionStatus;

  BookingBloc({
    required this.checkAvailability,
    required this.createBooking,
    required this.createInvoice,
    required this.cancelBooking,
    required this.updateBookingStatus,
    required this.getTransactionStatus,
  }) : super(BookingInitial()) {
    on<BookingAvailabilityChecked>(_onAvailabilityChecked);
    on<BookingSlotSelected>(_onSlotSelected);
    on<BookingCreated>(_onCreated);
    on<BookingPaymentCompleted>(_onPaymentCompleted);
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
          (failure) {
            print(
              'Check Hour $hour for Court $courtId on $date: FAILED - ${failure.message}',
            );
            availabilityMap[hour] = false; // Treat error as unavailable
          },
          (isAvailable) {
            print(
              'Check Hour $hour for Court $courtId on $date: Available: $isAvailable',
            );
            availabilityMap[hour] = isAvailable;
          },
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
      if (currentState.selectedStartTime != null &&
          currentState.selectedStartTime!.year == event.startTime.year &&
          currentState.selectedStartTime!.month == event.startTime.month &&
          currentState.selectedStartTime!.day == event.startTime.day &&
          currentState.selectedStartTime!.hour == event.startTime.hour) {
        // Deselect if the same slot is tapped again
        emit(currentState.copyWith(clearSelectedStartTime: true));
      } else {
        // Select new slot
        emit(currentState.copyWith(selectedStartTime: event.startTime));
      }
    }
  }

  Future<void> _onCreated(
    BookingCreated event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final bookingResult = await createBooking(
      CreateBookingParams(booking: event.booking),
    );
    await bookingResult.fold(
      (failure) async => emit(BookingFailure(failure.message)),
      (bookingId) async {
        // Assuming bookingId is also the orderId for Midtrans
        // And event.booking.totalPrice is the amount
        final invoiceResult = await createInvoice(
          CreateInvoiceParams(
            orderId: bookingId,
            amount:
                event.booking.totalPrice, // Assuming totalPrice is in booking
          ),
        );

        invoiceResult.fold(
          (failure) => emit(BookingFailure(failure.message)),
          (paymentInfo) => emit(
            BookingPaymentPageReady(
              paymentInfo.redirectUrl,
              bookingId, // Pass bookingId here
            ),
          ),
        );
      },
    );
  }

  Future<void> _onPaymentCompleted(
    BookingPaymentCompleted event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    if (event.status == 'success') {
      final result = await updateBookingStatus(
        UpdateBookingStatusParams(bookingId: event.bookingId, status: 'paid'),
      );
      result.fold(
        (failure) => emit(BookingFailure(failure.message)),
        (_) => emit(BookingPaidSuccess(event.bookingId)),
      );
    } else {
      // Payment failed or cancelled from WebView, re-query Midtrans API
      final statusResult = await getTransactionStatus(event.bookingId);
      await statusResult.fold(
        (failure) async => emit(BookingFailure(failure.message)),
        (midtransStatus) async {
          if (midtransStatus == 'settlement' || midtransStatus == 'capture') {
            final updateResult = await updateBookingStatus(
              UpdateBookingStatusParams(
                bookingId: event.bookingId,
                status: 'paid',
              ),
            );
            updateResult.fold(
              (failure) => emit(BookingFailure(failure.message)),
              (_) => emit(BookingPaidSuccess(event.bookingId)),
            );
          } else if (midtransStatus == 'pending') {
            // MVP Choice: Treat pending as cancelled to free up the slot immediately.
            final cancelResult = await cancelBooking(event.bookingId);
            cancelResult.fold(
              (failure) => emit(BookingFailure(failure.message)),
              (_) => emit(BookingCancelledState(event.bookingId)),
            );
          } else if (midtransStatus == 'expire' ||
              midtransStatus == 'cancel' ||
              midtransStatus == 'deny') {
            final cancelResult = await cancelBooking(event.bookingId);
            cancelResult.fold(
              (failure) => emit(BookingFailure(failure.message)),
              (_) => emit(BookingCancelledState(event.bookingId)),
            );
          } else {
            // Unknown status, treat as cancelled for now
            final cancelResult = await cancelBooking(event.bookingId);
            cancelResult.fold(
              (failure) => emit(BookingFailure(failure.message)),
              (_) => emit(BookingCancelledState(event.bookingId)),
            );
          }
        },
      );
    }
  }
}
