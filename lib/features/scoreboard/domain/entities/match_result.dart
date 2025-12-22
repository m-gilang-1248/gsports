import 'package:equatable/equatable.dart';
import 'match_set.dart';

class MatchResult extends Equatable {
  final String id;
  final String bookingId;
  final String sportType;
  final DateTime playedAt;
  final List<MatchSet> sets;
  final String winner; // 'Team A' or 'Team B'

  const MatchResult({
    required this.id,
    required this.bookingId,
    required this.sportType,
    required this.playedAt,
    required this.sets,
    required this.winner,
  });

  @override
  List<Object?> get props => [id, bookingId, sportType, playedAt, sets, winner];
}
