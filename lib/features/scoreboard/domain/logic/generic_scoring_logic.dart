import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/logic/scoring_logic.dart';

class GenericScoringLogic implements ScoringLogic {
  @override
  bool get usesSets => false;

  @override
  int get maxSets => 1;

  @override
  int get pointsToWinSet => 0; // Not applicable

  @override
  bool get isTimed => false;

  @override
  int get defaultDurationMinutes => 0;

  @override
  bool shouldFinishSet(int scoreA, int scoreB) => false; // Never finishes automatically

  @override
  bool shouldFinishMatch(List<MatchSet> history, int currentScoreA, int currentScoreB) => false; // Manual finish

  @override
  String? getWinner(List<MatchSet> history, int currentScoreA, int currentScoreB) {
    if (currentScoreA > currentScoreB) return 'Team A';
    if (currentScoreB > currentScoreA) return 'Team B';
    return 'Draw';
  }
}
