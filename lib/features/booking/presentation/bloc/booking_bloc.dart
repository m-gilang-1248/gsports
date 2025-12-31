import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:intl/intl.dart';
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
    on<BookingSelectionReset>((event, emit) => emit(BookingInitial()));
  }

  Future<void> _onAvailabilityChecked(
    BookingAvailabilityChecked event,
    Emitter<BookingState> emit,
  ) async {
    if (state is BookingAvailabilityLoaded &&
        (state as BookingAvailabilityLoaded).selectedCourtId == event.courtId) {
      emit((state as BookingAvailabilityLoaded).copyWith(isRefreshing: true));
    } else {
      emit(BookingLoading());
    }

    final availabilityMap = <int, bool>{};
    final date = event.date;
    final courtId = event.courtId;
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;

    // 1. Determine Operating Hours
    final dayOfWeek = DateFormat('EEEE').format(date);
    final hoursConfig =
        event.operatingHours?[dayOfWeek] as Map<String, dynamic>?;

    int startHour = 8;
    int endHour = 22;
    bool isOpen = true;

    if (hoursConfig != null) {
      isOpen = hoursConfig['isOpen'] as bool? ?? true;
      if (isOpen) {
        final openStr = hoursConfig['open'] as String? ?? '08:00';
        final closeStr = hoursConfig['close'] as String? ?? '22:00';
        startHour = int.tryParse(openStr.split(':')[0]) ?? 8;
        endHour = int.tryParse(closeStr.split(':')[0]) ?? 22;
      }
    }

    if (!isOpen) {
      emit(
        BookingAvailabilityLoaded(
          availabilityMap: const {},
          selectedCourtId: courtId,
          selectedDate: date,
          selectedSlots: const [],
          isRefreshing: false,
        ),
      );
      return;
    }

    // 2. Determine Past Hours if date is today
    final now = DateTime.now();
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    final futures = <Future<void>>[];

    for (int hour = startHour; hour < endHour; hour++) {
      // Check for past time
      if (isToday && hour <= now.hour) {
        availabilityMap[hour] = false;
        continue;
      }

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
        selectedSlots: const [],
        isRefreshing: false,
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
        // If booking is already paid (e.g. Manual Booking), skip Midtrans
        if (event.booking.status == 'paid') {
          // Force update status to ensure it persists as 'paid'
          // This handles cases where Firestore triggers might default it to 'waiting_payment'
          await updateBookingStatus(
            UpdateBookingStatusParams(bookingId: bookingId, status: 'paid'),
          );
          emit(BookingPaidSuccess(bookingId));
          return;
        }

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
