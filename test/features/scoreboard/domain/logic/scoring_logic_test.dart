import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_configuration.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/logic/scoring_logic.dart';

void main() {
  group('ScoringLogic - Badminton', () {
    late ScoringLogic logic;

    setUp(() {
      final config = MatchConfiguration.forSport('badminton');
      logic = ScoringLogic(config);
    });

    test('should finish set at 21-19', () {
      expect(logic.shouldFinishSet(21, 19), true);
    });

    test('should NOT finish set at 20-19', () {
      expect(logic.shouldFinishSet(20, 19), false);
    });

    test('should NOT finish set at 21-20 (deuce)', () {
      expect(logic.shouldFinishSet(21, 20), false);
    });

    test('should finish set at 22-20 (deuce win)', () {
      expect(logic.shouldFinishSet(22, 20), true);
    });

    test('should finish set at 30-29 (max cap)', () {
      // Config default maxScorePerSet is 30 for badminton
      expect(logic.shouldFinishSet(30, 29), true);
    });

    test('should finish match when team wins 2 sets', () {
      final history = [
        const MatchSet(scoreA: 21, scoreB: 19),
        const MatchSet(scoreA: 21, scoreB: 15),
      ];
      expect(logic.shouldFinishMatch(history, 0, 0), true);
      expect(logic.getWinner(history, 0, 0), 'Team A');
    });
  });

  group('ScoringLogic - Futsal (TimeBased)', () {
    late ScoringLogic logic;

    setUp(() {
      final config = MatchConfiguration.forSport('futsal');
      logic = ScoringLogic(config);
    });

    test('should NOT finish set by score', () {
      expect(logic.shouldFinishSet(100, 0), false);
    });

    test('should finish period by time', () {
      // 20 mins = 1200 seconds
      expect(logic.shouldFinishPeriodByTime(1199), false);
      expect(logic.shouldFinishPeriodByTime(1200), true);
    });

    test('should finish match after 2 periods', () {
      final history = [
        const MatchSet(scoreA: 1, scoreB: 0),
        const MatchSet(scoreA: 2, scoreB: 1),
      ];
      expect(logic.shouldFinishMatch(history, 0, 0), true);
    });
  });
}
