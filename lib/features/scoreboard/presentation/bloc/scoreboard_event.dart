part of 'scoreboard_bloc.dart';

abstract class ScoreboardEvent extends Equatable {
  const ScoreboardEvent();

  @override
  List<Object> get props => [];
}

class IncrementScoreA extends ScoreboardEvent {}

class IncrementScoreB extends ScoreboardEvent {}

class DecrementScoreA extends ScoreboardEvent {}

class DecrementScoreB extends ScoreboardEvent {}

class UndoLastAction extends ScoreboardEvent {}

class ResetMatch extends ScoreboardEvent {}

class ToggleTimer extends ScoreboardEvent {}

class InitializeScoreboard extends ScoreboardEvent {
  final String sportType;

  const InitializeScoreboard(this.sportType);

  @override
  List<Object> get props => [sportType];
}

class SaveMatchRequested extends ScoreboardEvent {
  final String bookingId;
  final String sportType;
  final List<String> players;
  final List<String> teamAIds;
  final List<String> teamBIds;
  final String teamAName;
  final String teamBName;
  final Map<String, String> playerNames;
  final String? venueName;
  final String? courtName;
  final DateTime? startTime;
  final DateTime? endTime;
  final int durationSeconds;

  const SaveMatchRequested({
    required this.bookingId,
    required this.sportType,
    required this.players,
    required this.teamAIds,
    required this.teamBIds,
    required this.teamAName,
    required this.teamBName,
    required this.playerNames,
    this.venueName,
    this.courtName,
    this.startTime,
    this.endTime,
    required this.durationSeconds,
  });

  @override
  List<Object> get props => [
    bookingId,
    sportType,
    players,
    teamAIds,
    teamBIds,
    teamAName,
    teamBName,
    playerNames,
    durationSeconds,
  ];
}
