import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';

abstract class ScoringLogic {
  bool get usesSets;
  int get maxSets;
  int get pointsToWinSet;
  
  // Time-based rules
  bool get isTimed;
  int get defaultDurationMinutes;

  /// Returns true if the set should finish based on current scores.
  bool shouldFinishSet(int scoreA, int scoreB);

  /// Returns true if the entire match should finish.
  bool shouldFinishMatch(List<MatchSet> history, int currentScoreA, int currentScoreB);

  /// Returns the winner name ('Team A' or 'Team B') or null if not finished.
  String? getWinner(List<MatchSet> history, int currentScoreA, int currentScoreB);
}
