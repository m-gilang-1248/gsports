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

class JoinBookingRequested extends HistoryEvent {
  final String splitCode;
  final String userId; // Need userId to create PaymentParticipant

  const JoinBookingRequested(this.splitCode, this.userId);

  @override
  List<Object> get props => [splitCode, userId];
}
