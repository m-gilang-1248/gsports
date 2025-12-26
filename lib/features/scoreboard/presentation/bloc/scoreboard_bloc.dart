import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';

import 'package:gsports/features/scoreboard/domain/logic/badminton_scoring_logic.dart';
import 'package:gsports/features/scoreboard/domain/logic/generic_scoring_logic.dart';
import 'package:gsports/features/scoreboard/domain/logic/scoring_logic.dart';

import 'package:gsports/features/scoreboard/domain/logic/futsal_scoring_logic.dart';

part 'scoreboard_event.dart';
part 'scoreboard_state.dart';

@injectable
class ScoreboardBloc extends Bloc<ScoreboardEvent, ScoreboardState> {
  final ScoreboardRepository repository;
  ScoringLogic _scoringLogic = GenericScoringLogic();
  String _currentSportType = '';

  ScoreboardBloc(this.repository) : super(const ScoreboardState()) {
    on<InitializeScoreboard>(_onInitializeScoreboard);
    on<IncrementScoreA>(_onIncrementScoreA);
    on<IncrementScoreB>(_onIncrementScoreB);
    on<DecrementScoreA>(_onDecrementScoreA);
    on<DecrementScoreB>(_onDecrementScoreB);
    on<UndoLastAction>(_onUndoLastAction);
    on<ResetMatch>(_onResetMatch);
    on<ToggleTimer>(_onToggleTimer);
    on<SaveMatchRequested>(_onSaveMatchRequested);
  }

  void _onInitializeScoreboard(
    InitializeScoreboard event,
    Emitter<ScoreboardState> emit,
  ) {
    _currentSportType = event.sportType.toLowerCase();
    if (_currentSportType.contains('badminton')) {
      _scoringLogic = BadmintonScoringLogic();
    } else if (_currentSportType.contains('futsal')) {
      _scoringLogic = FutsalScoringLogic();
    } else {
      _scoringLogic = GenericScoringLogic();
    }
    emit(
      state.copyWith(
        usesSets: _scoringLogic.usesSets,
        isTimed: _scoringLogic.isTimed,
        targetDurationMinutes: _scoringLogic.defaultDurationMinutes,
      ),
    );
  }

  void _onIncrementScoreA(
    IncrementScoreA event,
    Emitter<ScoreboardState> emit,
  ) {
    if (state.isMatchFinished) return;
    _saveStateForUndo(emit);
    _processScore(emit, state.scoreA + 1, state.scoreB);
  }

  void _onIncrementScoreB(
    IncrementScoreB event,
    Emitter<ScoreboardState> emit,
  ) {
    if (state.isMatchFinished) return;
    _saveStateForUndo(emit);
    _processScore(emit, state.scoreA, state.scoreB + 1);
  }

  void _onDecrementScoreA(
    DecrementScoreA event,
    Emitter<ScoreboardState> emit,
  ) {
    if (state.isMatchFinished || state.scoreA <= 0) return;
    _saveStateForUndo(emit);
    emit(state.copyWith(scoreA: state.scoreA - 1));
  }

  void _onDecrementScoreB(
    DecrementScoreB event,
    Emitter<ScoreboardState> emit,
  ) {
    if (state.isMatchFinished || state.scoreB <= 0) return;
    _saveStateForUndo(emit);
    emit(state.copyWith(scoreB: state.scoreB - 1));
  }

  void _processScore(
    Emitter<ScoreboardState> emit,
    int newScoreA,
    int newScoreB,
  ) {
    if (_scoringLogic.shouldFinishSet(newScoreA, newScoreB)) {
      final finishedSet = MatchSet(scoreA: newScoreA, scoreB: newScoreB);
      final newHistory = List<MatchSet>.from(state.historySets)
        ..add(finishedSet);

      if (_scoringLogic.shouldFinishMatch(newHistory, newScoreA, newScoreB)) {
        emit(
          state.copyWith(
            scoreA: newScoreA,
            scoreB: newScoreB,
            historySets: newHistory,
            isMatchFinished: true,
            winner: _scoringLogic.getWinner(newHistory, newScoreA, newScoreB),
          ),
        );
      } else {
        // Start Next Set
        emit(
          state.copyWith(
            scoreA: 0,
            scoreB: 0,
            currentSet: state.currentSet + 1,
            historySets: newHistory,
          ),
        );
      }
    } else {
      // Just update score
      emit(state.copyWith(scoreA: newScoreA, scoreB: newScoreB));
    }
  }

  void _onToggleTimer(ToggleTimer event, Emitter<ScoreboardState> emit) {
    emit(state.copyWith(isTimerPaused: !state.isTimerPaused));
  }

  void _saveStateForUndo(Emitter<ScoreboardState> emit) {
    // Limit stack size if needed, e.g., max 10
    final newStack = List<ScoreboardState>.from(state.undoStack)..add(state);
    emit(state.copyWith(undoStack: newStack));
  }

  void _onUndoLastAction(UndoLastAction event, Emitter<ScoreboardState> emit) {
    if (state.undoStack.isNotEmpty) {
      final previousState = state.undoStack.last;
      final newStack = List<ScoreboardState>.from(state.undoStack)
        ..removeLast();

      // Restore state but update the stack
      emit(previousState.copyWith(undoStack: newStack));
    }
  }

  void _onResetMatch(ResetMatch event, Emitter<ScoreboardState> emit) {
    emit(
      ScoreboardState(
        usesSets: _scoringLogic.usesSets,
        isTimed: _scoringLogic.isTimed,
        targetDurationMinutes: _scoringLogic.defaultDurationMinutes,
      ),
    );
  }

  Future<void> _onSaveMatchRequested(
    SaveMatchRequested event,
    Emitter<ScoreboardState> emit,
  ) async {
    if (!state.isMatchFinished) return;

    emit(
      state.copyWith(isSaving: true, saveSuccess: false, errorMessage: null),
    );

    final match = MatchResult(
      id: '', // Generated by Firestore
      bookingId: event.bookingId,
      sportType: event.sportType,
      playedAt: DateTime.now(),
      durationSeconds: event.durationSeconds,
      players: event.players,
      teamAIds: event.teamAIds,
      teamBIds: event.teamBIds,
      teamAName: event.teamAName,
      teamBName: event.teamBName,
      playerNames: event.playerNames,
      venueName: event.venueName,
      courtName: event.courtName,
      startTime: event.startTime,
      endTime: event.endTime,
      sets: state.historySets,
      winner: state.winner!,
    );

    final result = await repository.saveMatch(match);

    result.fold(
      (failure) =>
          emit(state.copyWith(isSaving: false, errorMessage: failure.message)),
      (_) => emit(state.copyWith(isSaving: false, saveSuccess: true)),
    );
  }
}
