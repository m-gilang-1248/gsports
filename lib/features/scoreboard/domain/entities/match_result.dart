import 'package:equatable/equatable.dart';
import 'match_set.dart';

class MatchResult extends Equatable {
  final String id;
  final String bookingId;
  final String sportType;
  final DateTime playedAt;
  final int durationSeconds; // Added duration
  final List<String> players; // Added players UIDs
  final List<String> teamAIds;
  final List<String> teamBIds;
  final List<MatchSet> sets;
  final String winner; // 'Team A' or 'Team B'

  const MatchResult({
    required this.id,
    required this.bookingId,
    required this.sportType,
    required this.playedAt,
    required this.durationSeconds,
    required this.players,
    required this.teamAIds,
    required this.teamBIds,
    required this.sets,
    required this.winner,
  });

  @override
  List<Object?> get props => [
    id,
    bookingId,
    sportType,
    playedAt,
    durationSeconds,
    players,
    teamAIds,
    teamBIds,
    sets,
    winner,
  ];
}
