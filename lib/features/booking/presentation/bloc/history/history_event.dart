part of 'history_bloc.dart';

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => [];
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

class UpdateBookingSportFilter extends HistoryEvent {
  final String? sportId;
  const UpdateBookingSportFilter(this.sportId);

  @override
  List<Object?> get props => [sportId];
}

class UpdateBookingTimeFilter extends HistoryEvent {
  final TimeFilterPreset preset;
  final DateTime? customDate;

  const UpdateBookingTimeFilter({required this.preset, this.customDate});

  @override
  List<Object?> get props => [preset, customDate];
}
