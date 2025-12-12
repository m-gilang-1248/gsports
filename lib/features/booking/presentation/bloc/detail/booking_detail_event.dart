part of 'booking_detail_bloc.dart';

abstract class BookingDetailEvent extends Equatable {
  const BookingDetailEvent();

  @override
  List<Object> get props => [];
}

class FetchBookingDetail extends BookingDetailEvent {
  final String bookingId;

  const FetchBookingDetail(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}

class GenerateCodeRequested extends BookingDetailEvent {
  final String bookingId;

  const GenerateCodeRequested(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
