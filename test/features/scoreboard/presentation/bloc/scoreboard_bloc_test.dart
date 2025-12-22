import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';
import 'package:gsports/features/scoreboard/presentation/bloc/scoreboard_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockScoreboardRepository extends Mock implements ScoreboardRepository {}
class FakeMatchResult extends Fake implements MatchResult {}

void main() {
  late ScoreboardBloc bloc;
  late MockScoreboardRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeMatchResult());
  });

  setUp(() {
    mockRepository = MockScoreboardRepository();
    bloc = ScoreboardBloc(mockRepository);
  });

  group('ScoreboardBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, const ScoreboardState());
    });

    blocTest<ScoreboardBloc, ScoreboardState>(
      'increments score A correctly',
      build: () => bloc,
      act: (bloc) => bloc.add(IncrementScoreA()),
      expect: () => [
        isA<ScoreboardState>(), // Undo save
        isA<ScoreboardState>().having((s) => s.scoreA, 'scoreA', 1),
      ],
    );

    blocTest<ScoreboardBloc, ScoreboardState>(
      'increments score B correctly',
      build: () => bloc,
      act: (bloc) => bloc.add(IncrementScoreB()),
      expect: () => [
        isA<ScoreboardState>(), // Undo save
        isA<ScoreboardState>().having((s) => s.scoreB, 'scoreB', 1),
      ],
    );

    blocTest<ScoreboardBloc, ScoreboardState>(
      'winning a set resets scores and increments set counter',
      build: () => bloc,
      seed: () => const ScoreboardState(scoreA: 20, scoreB: 10, currentSet: 1),
      act: (bloc) => bloc.add(IncrementScoreA()), // 21-10 -> Win Set 1
      expect: () => [
        // Undo save swallowed because props equal to seed
        isA<ScoreboardState>()
            .having((s) => s.scoreA, 'scoreA', 0)
            .having((s) => s.currentSet, 'currentSet', 2)
            .having((s) => s.historySets.length, 'historySets', 1)
            .having((s) => s.historySets.first, 'first set', const MatchSet(scoreA: 21, scoreB: 10)),
      ],
    );

    blocTest<ScoreboardBloc, ScoreboardState>(
      'deuce logic: 20-20 requires 2 point lead',
      build: () => bloc,
      seed: () => const ScoreboardState(scoreA: 20, scoreB: 20, currentSet: 1),
      act: (bloc) {
        bloc.add(IncrementScoreA()); // 21-20 (Not won yet)
      },
      expect: () => [
        // Undo save swallowed
        isA<ScoreboardState>().having((s) => s.scoreA, 'scoreA', 21).having((s) => s.currentSet, 'currentSet', 1),
      ],
    );

    blocTest<ScoreboardBloc, ScoreboardState>(
      'deuce logic: 22-20 wins set',
      build: () => bloc,
      seed: () => const ScoreboardState(scoreA: 21, scoreB: 20, currentSet: 1),
      act: (bloc) => bloc.add(IncrementScoreA()), // 22-20 -> Win
      expect: () => [
        // Undo save swallowed
        isA<ScoreboardState>().having((s) => s.currentSet, 'currentSet', 2),
      ],
    );

    blocTest<ScoreboardBloc, ScoreboardState>(
      'max score logic: 30-29 wins set',
      build: () => bloc,
      seed: () => const ScoreboardState(scoreA: 29, scoreB: 29, currentSet: 1),
      act: (bloc) => bloc.add(IncrementScoreA()), // 30-29 -> Win (Golden Point)
      expect: () => [
        // Undo save swallowed
        isA<ScoreboardState>().having((s) => s.currentSet, 'currentSet', 2),
      ],
    );

    blocTest<ScoreboardBloc, ScoreboardState>(
      'undo restores previous state',
      build: () => bloc,
      seed: () => const ScoreboardState(scoreA: 1, scoreB: 0, undoStack: [ScoreboardState()]),
      act: (bloc) => bloc.add(UndoLastAction()),
      expect: () => [
        // Undo does NOT save state, so only 1 emission
        const ScoreboardState(scoreA: 0, scoreB: 0),
      ],
    );
  });
}
