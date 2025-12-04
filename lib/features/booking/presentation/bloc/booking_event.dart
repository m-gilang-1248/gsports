part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object> get props => [];
}

class BookingAvailabilityChecked extends BookingEvent {
  final String courtId;
  final DateTime date;

  const BookingAvailabilityChecked({required this.courtId, required this.date});

  @override
  List<Object> get props => [courtId, date];
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
