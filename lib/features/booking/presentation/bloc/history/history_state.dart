part of 'history_bloc.dart';

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryInitial extends HistoryState {}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<Booking> bookings;

  const HistoryLoaded(this.bookings);

  @override
  List<Object> get props => [bookings];
}

class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

class HistoryJoinSuccess extends HistoryState {
  final String bookingId;

  const HistoryJoinSuccess(this.bookingId);

  @override
  List<Object> get props => [bookingId];
}
