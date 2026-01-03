import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';
import 'package:gsports/features/scoreboard/presentation/bloc/match_history/match_history_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockScoreboardRepository extends Mock implements ScoreboardRepository {}

void main() {
  late MatchHistoryBloc bloc;
  late MockScoreboardRepository mockRepository;

  final tMatch1 = MatchResult(
    id: '1',
    bookingId: 'b1',
    sportType: 'badminton',
    playedAt: DateTime.now(),
    durationSeconds: 1200,
    players: [],
    teamAIds: [],
    teamBIds: [],
    teamAName: 'Team A',
    teamBName: 'Team B',
    playerNames: {},
    venueName: 'Venue A',
    courtName: 'Court 1',
    startTime: DateTime.now(),
    endTime: DateTime.now().add(const Duration(hours: 1)),
    sets: [],
    winner: 'Team A',
  );

  final tMatch2 = MatchResult(
    id: '2',
    bookingId: 'b2',
    sportType: 'futsal',
    playedAt: DateTime.now().subtract(const Duration(days: 10)),
    durationSeconds: 2400,
    players: [],
    teamAIds: [],
    teamBIds: [],
    teamAName: 'Team A',
    teamBName: 'Team B',
    playerNames: {},
    venueName: 'Venue A',
    courtName: 'Court 1',
    startTime: DateTime.now().subtract(const Duration(days: 10)),
    endTime: DateTime.now().subtract(const Duration(days: 10, hours: -1)),
    sets: [],
    winner: 'Team B',
  );

  setUp(() {
    mockRepository = MockScoreboardRepository();
    bloc = MatchHistoryBloc(mockRepository);
  });

  group('MatchHistoryBloc', () {
    test('initial state is correct', () {
      expect(bloc.state, const MatchHistoryState());
    });

    blocTest<MatchHistoryBloc, MatchHistoryState>(
      'LoadMatchHistory emits loading and then loaded with all matches',
      build: () {
        when(
          () => mockRepository.getMatchesByUser(any()),
        ).thenAnswer((_) async => Right([tMatch1, tMatch2]));
        return bloc;
      },
      act: (bloc) => bloc.add(const LoadMatchHistory('user1')),
      expect: () => [
        const MatchHistoryState(status: MatchHistoryStatus.loading),
        MatchHistoryState(
          status: MatchHistoryStatus.loaded,
          allMatches: [tMatch1, tMatch2],
          filteredMatches: [tMatch1, tMatch2],
        ),
      ],
    );

    blocTest<MatchHistoryBloc, MatchHistoryState>(
      'UpdateSportFilter filters matches correctly',
      build: () => bloc,
      seed: () => MatchHistoryState(
        status: MatchHistoryStatus.loaded,
        allMatches: [tMatch1, tMatch2],
        filteredMatches: [tMatch1, tMatch2],
      ),
      act: (bloc) => bloc.add(const UpdateSportFilter('futsal')),
      expect: () => [
        MatchHistoryState(
          status: MatchHistoryStatus.loaded,
          allMatches: [tMatch1, tMatch2],
          filteredMatches: [tMatch2],
          selectedSportId: 'futsal',
        ),
      ],
    );

    blocTest<MatchHistoryBloc, MatchHistoryState>(
      'UpdateTimeFilter filters matches correctly (This Week)',
      build: () => bloc,
      seed: () => MatchHistoryState(
        status: MatchHistoryStatus.loaded,
        allMatches: [tMatch1, tMatch2],
        filteredMatches: [tMatch1, tMatch2],
      ),
      act: (bloc) =>
          bloc.add(const UpdateTimeFilter(preset: TimeFilterPreset.thisWeek)),
      expect: () => [
        MatchHistoryState(
          status: MatchHistoryStatus.loaded,
          allMatches: [tMatch1, tMatch2],
          filteredMatches: [tMatch1],
          selectedTimePreset: TimeFilterPreset.thisWeek,
        ),
      ],
    );
  });
}
