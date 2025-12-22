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
  final List<MatchResult> matches;
  final bool isUpdatingParticipant;

  const BookingDetailLoaded(
    this.booking, {
    this.matches = const [],
    this.isUpdatingParticipant = false,
  });

  @override
  List<Object> get props => [booking, matches, isUpdatingParticipant];

  BookingDetailLoaded copyWith({
    Booking? booking,
    List<MatchResult>? matches,
    bool? isUpdatingParticipant,
  }) {
    return BookingDetailLoaded(
      booking ?? this.booking,
      matches: matches ?? this.matches,
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
