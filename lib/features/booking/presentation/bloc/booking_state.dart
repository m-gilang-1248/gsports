part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingAvailabilityLoaded extends BookingState {
  final Map<int, bool> availabilityMap; // Hour -> IsAvailable
  final String selectedCourtId;
  final DateTime selectedDate;
  final DateTime? selectedStartTime; // Nullable if no slot selected yet

  const BookingAvailabilityLoaded({
    required this.availabilityMap,
    required this.selectedCourtId,
    required this.selectedDate,
    this.selectedStartTime,
  });

  @override
  List<Object?> get props => [
    availabilityMap,
    selectedCourtId,
    selectedDate,
    selectedStartTime,
  ];

  BookingAvailabilityLoaded copyWith({
    Map<int, bool>? availabilityMap,
    String? selectedCourtId,
    DateTime? selectedDate,
    DateTime? selectedStartTime,
    bool clearSelectedStartTime = false,
  }) {
    return BookingAvailabilityLoaded(
      availabilityMap: availabilityMap ?? this.availabilityMap,
      selectedCourtId: selectedCourtId ?? this.selectedCourtId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedStartTime: clearSelectedStartTime
          ? null
          : (selectedStartTime ?? this.selectedStartTime),
    );
  }
}

class BookingSuccess extends BookingState {
  final String bookingId;

  const BookingSuccess(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class BookingFailure extends BookingState {
  final String message;

  const BookingFailure(this.message);

  @override
  List<Object> get props => [message];
}

class BookingPaymentPageReady extends BookingState {
  final String paymentUrl;
  final String bookingId;

  const BookingPaymentPageReady(this.paymentUrl, this.bookingId);

  @override
  List<Object> get props => [paymentUrl, bookingId];
}

class BookingPaidSuccess extends BookingState {
  final String bookingId;

  const BookingPaidSuccess(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class BookingCancelledState extends BookingState {
  final String bookingId;

  const BookingCancelledState(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class BookingWaitingForPayment extends BookingState {
  final String bookingId;

  const BookingWaitingForPayment(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
