import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/logic/scoring_logic.dart';

class FutsalScoringLogic implements ScoringLogic {
  @override
  bool get usesSets => false;

  @override
  int get maxSets => 1;

  @override
  int get pointsToWinSet => 0;

  @override
  bool get isTimed => true;

  @override
  int get defaultDurationMinutes => 40; // 2 x 20 minutes usually

  @override
  bool shouldFinishSet(int scoreA, int scoreB) => false;

  @override
  bool shouldFinishMatch(List<MatchSet> history, int currentScoreA, int currentScoreB) => false;

  @override
  String? getWinner(List<MatchSet> history, int currentScoreA, int currentScoreB) {
    if (currentScoreA > currentScoreB) return 'Team A';
    if (currentScoreB > currentScoreA) return 'Team B';
    return 'Draw';
  }
}
