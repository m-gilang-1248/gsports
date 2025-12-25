import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/logic/scoring_logic.dart';

class BadmintonScoringLogic implements ScoringLogic {
  @override
  bool get usesSets => true;

  @override
  int get maxSets => 3;

  @override
  int get pointsToWinSet => 21;

  @override
  bool get isTimed => false;

  @override
  int get defaultDurationMinutes => 0;

  @override
  bool shouldFinishSet(int scoreA, int scoreB) {
    if (scoreA >= 30 || scoreB >= 30) return true;
    if (scoreA >= 21 || scoreB >= 21) {
      return (scoreA - scoreB).abs() >= 2;
    }
    return false;
  }

  @override
  bool shouldFinishMatch(List<MatchSet> history, int currentScoreA, int currentScoreB) {
    int winsA = history.where((s) => s.scoreA > s.scoreB).length;
    int winsB = history.where((s) => s.scoreB > s.scoreA).length;

    // Current set is not in history yet when this is called in some contexts,
    // but usually we check after adding to history.
    return winsA == 2 || winsB == 2;
  }

  @override
  String? getWinner(List<MatchSet> history, int currentScoreA, int currentScoreB) {
    int winsA = history.where((s) => s.scoreA > s.scoreB).length;
    int winsB = history.where((s) => s.scoreB > s.scoreA).length;

    if (winsA == 2) return 'Team A';
    if (winsB == 2) return 'Team B';
    return null;
  }
}
