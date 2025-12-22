part of 'scoreboard_bloc.dart';

abstract class ScoreboardEvent extends Equatable {
  const ScoreboardEvent();

  @override
  List<Object> get props => [];
}

class IncrementScoreA extends ScoreboardEvent {}

class IncrementScoreB extends ScoreboardEvent {}

class UndoLastAction extends ScoreboardEvent {}

class ResetMatch extends ScoreboardEvent {}

class SaveMatchRequested extends ScoreboardEvent {
  final String bookingId;
  final String sportType;

  const SaveMatchRequested({required this.bookingId, required this.sportType});

  @override
  List<Object> get props => [bookingId, sportType];
}
