part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class BookingAvailabilityChecked extends BookingEvent {
  final String courtId;
  final DateTime date;
  final Map<String, dynamic>? operatingHours;

  const BookingAvailabilityChecked({
    required this.courtId,
    required this.date,
    this.operatingHours,
  });

  @override
  List<Object> get props => [courtId, date, operatingHours ?? {}];
}

class BookingSlotSelected extends BookingEvent {
  final DateTime startTime;

  const BookingSlotSelected(this.startTime);

  @override
  List<Object> get props => [startTime];
}

class BookingCreated extends BookingEvent {
  final Booking booking;

  const BookingCreated(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingPaymentCompleted extends BookingEvent {
  final String bookingId;
  final String status; // 'success', 'failed', 'cancelled'

  const BookingPaymentCompleted({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object> get props => [bookingId, status];
}
