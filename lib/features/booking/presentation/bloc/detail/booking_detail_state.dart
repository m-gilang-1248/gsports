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
  final bool isUpdatingParticipant;

  const BookingDetailLoaded(
    this.booking, {
    this.isUpdatingParticipant = false,
  });

  @override
  List<Object> get props => [booking, isUpdatingParticipant];

  BookingDetailLoaded copyWith({
    Booking? booking,
    bool? isUpdatingParticipant,
  }) {
    return BookingDetailLoaded(
      booking ?? this.booking,
      isUpdatingParticipant:
          isUpdatingParticipant ?? this.isUpdatingParticipant,
    );
  }
}

class BookingDetailError extends BookingDetailState {
  final String message;

  const BookingDetailError(this.message);

  @override
  List<Object> get props => [message];
}
