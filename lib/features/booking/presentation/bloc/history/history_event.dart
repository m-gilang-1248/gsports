part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class FetchBookingHistory extends HistoryEvent {
  final String userId;

  const FetchBookingHistory(this.userId);

  @override
  List<Object> get props => [userId];
}
