part of 'booking_detail_bloc.dart';

abstract class BookingDetailState extends Equatable {
  const BookingDetailState();

  @override
  List<Object> get props => [];
}

class BookingDetailInitial extends BookingDetailState {}

class BookingDetailLoading extends BookingDetailState {}

class BookingDetailLoaded extends BookingDetailState {
  final Booking booking;

  const BookingDetailLoaded(this.booking);

  @override
  List<Object> get props => [booking];
}

class BookingDetailError extends BookingDetailState {
  final String message;

  const BookingDetailError(this.message);

  @override
  List<Object> get props => [message];
}
