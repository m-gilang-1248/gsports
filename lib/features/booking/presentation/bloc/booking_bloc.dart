import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/usecases/check_availability.dart';
import 'package:gsports/features/booking/domain/usecases/create_booking.dart';
import 'package:gsports/features/booking/domain/usecases/cancel_booking.dart';
import 'package:gsports/features/booking/domain/usecases/update_booking_status.dart';
import 'package:gsports/features/booking/domain/usecases/update_payment_info.dart';
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
  final UpdatePaymentInfo updatePaymentInfo;

  BookingBloc({
    required this.checkAvailability,
    required this.createBooking,
    required this.createInvoice,
    required this.cancelBooking,
    required this.updateBookingStatus,
    required this.getTransactionStatus,
    required this.updatePaymentInfo,
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
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // Check hours 08:00 to 22:00 (inclusive start)
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
            // If guest and error occurs (e.g. permission), default to AVAILABLE
            // This ensures they can select a slot and see the login redirect.
            availabilityMap[hour] = !isLoggedIn;
          },
          (isAvailable) {
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
        selectedSlots: const [], // Reset selection on new check
      ),
    );
  }

  void _onSlotSelected(BookingSlotSelected event, Emitter<BookingState> emit) {
    if (state is BookingAvailabilityLoaded) {
      final currentState = state as BookingAvailabilityLoaded;
      final selectedSlots = List<DateTime>.from(currentState.selectedSlots);
      final tappedSlot = event.startTime;

      if (selectedSlots.isEmpty) {
        selectedSlots.add(tappedSlot);
      } else {
        final isSelected = selectedSlots.any(
          (s) => s.isAtSameMomentAs(tappedSlot),
        );

        if (isSelected) {
          // Deselection logic: Trim tail
          final index = selectedSlots.indexWhere(
            (s) => s.isAtSameMomentAs(tappedSlot),
          );
          selectedSlots.removeRange(index, selectedSlots.length);
        } else {
          // Check if consecutive
          selectedSlots.sort();
          final first = selectedSlots.first;
          final last = selectedSlots.last;

          final isNext = tappedSlot.isAtSameMomentAs(
            last.add(const Duration(hours: 1)),
          );
          final isPrev = tappedSlot.isAtSameMomentAs(
            first.subtract(const Duration(hours: 1)),
          );

          if (isNext) {
            selectedSlots.add(tappedSlot);
          } else if (isPrev) {
            selectedSlots.insert(0, tappedSlot);
          } else {
            // Not consecutive: Reset and select only new
            selectedSlots.clear();
            selectedSlots.add(tappedSlot);
          }
        }
      }

      selectedSlots.sort();
      emit(currentState.copyWith(selectedSlots: selectedSlots));
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

        await invoiceResult.fold(
          (failure) async => emit(BookingFailure(failure.message)),
          (paymentInfo) async {
            // Update Booking with Payment URL & Order ID
            final updateInfoResult = await updatePaymentInfo(
              UpdatePaymentInfoParams(
                bookingId: bookingId,
                paymentUrl: paymentInfo.redirectUrl,
                orderId: bookingId,
              ),
            );

            updateInfoResult.fold(
              (failure) => emit(BookingFailure(failure.message)),
              (_) => emit(
                BookingPaymentPageReady(paymentInfo.redirectUrl, bookingId),
              ),
            );
          },
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
          } else if (midtransStatus == 'pending' ||
              midtransStatus == 'not_found') {
            // Keep slot reserved for 15 mins (handled by custom_expiry).
            // Update status to waiting_payment instead of cancelling.
            final updateResult = await updateBookingStatus(
              UpdateBookingStatusParams(
                bookingId: event.bookingId,
                status: 'waiting_payment',
              ),
            );
            updateResult.fold(
              (failure) => emit(BookingFailure(failure.message)),
              (_) => emit(BookingWaitingForPayment(event.bookingId)),
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
