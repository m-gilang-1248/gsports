import 'package:gsports/features/scoreboard/domain/entities/match_configuration.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';

class ScoringLogic {
  final MatchConfiguration config;

  ScoringLogic(this.config);

  bool get usesSets =>
      config.numberOfPeriods > 1 || config.winningSetsNeeded > 1;

  // For TimeBased, "Max Sets" is actually "Max Periods"
  int get maxSets => config.scoringType == ScoringType.timeBased
      ? config.numberOfPeriods
      : (config.winningSetsNeeded * 2) - 1; // e.g. best of 3 needs max 3 sets

  int get pointsToWinSet => config.winningScorePerSet;

  bool get isTimed => config.scoringType == ScoringType.timeBased;

  int get defaultDurationMinutes =>
      (config.durationPerPeriodSeconds / 60).round();

  bool shouldFinishSet(int scoreA, int scoreB) {
    if (config.scoringType == ScoringType.timeBased) {
      // Time-based sets/periods don't finish by score
      return false;
    }

    if (scoreA < config.winningScorePerSet &&
        scoreB < config.winningScorePerSet) {
      return false;
    }

    if (config.deuceEnabled) {
      // Check for max score cap (e.g., 30 in Badminton)
      if (scoreA >= config.maxScorePerSet || scoreB >= config.maxScorePerSet) {
        return true;
      }
      // Must win by 2
      return (scoreA - scoreB).abs() >= 2;
    } else {
      // First to reach target
      return scoreA >= config.winningScorePerSet ||
          scoreB >= config.winningScorePerSet;
    }
  }

  bool shouldFinishMatch(
    List<MatchSet> history,
    int currentScoreA,
    int currentScoreB,
  ) {
    if (config.scoringType == ScoringType.timeBased) {
      // Finished if all periods are played
      // history.length is number of COMPLETED sets/periods.
      // If history.length == config.numberOfPeriods, match is over.
      return history.length >= config.numberOfPeriods;
    } else {
      // Points based (Best of N)
      int winsA = history.where((s) => s.scoreA > s.scoreB).length;
      int winsB = history.where((s) => s.scoreB > s.scoreA).length;

      return winsA >= config.winningSetsNeeded ||
          winsB >= config.winningSetsNeeded;
    }
  }

  String? getWinner(
    List<MatchSet> history,
    int currentScoreA,
    int currentScoreB,
  ) {
    if (config.scoringType == ScoringType.timeBased) {
      // Sum all scores
      int totalA = 0;
      int totalB = 0;
      for (var set in history) {
        totalA += set.scoreA;
        totalB += set.scoreB;
      }
      // If currently playing last period (or after it finished but added to history), include current?
      // Actually 'history' contains completed sets.
      // If match is finished, history contains all sets.

      if (totalA > totalB) return 'Team A';
      if (totalB > totalA) return 'Team B';
      return 'Draw';
    } else {
      int winsA = history.where((s) => s.scoreA > s.scoreB).length;
      int winsB = history.where((s) => s.scoreB > s.scoreA).length;

      if (winsA >= config.winningSetsNeeded) return 'Team A';
      if (winsB >= config.winningSetsNeeded) return 'Team B';
      return null;
    }
  }

  // New helper for Time Based logic
  bool shouldFinishPeriodByTime(int elapsedSeconds) {
    if (!config.autoStopTimer) return false;
    return elapsedSeconds >= config.durationPerPeriodSeconds;
  }
}
