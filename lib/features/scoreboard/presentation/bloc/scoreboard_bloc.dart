import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_configuration.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_set.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';
import 'package:gsports/features/scoreboard/domain/logic/scoring_logic.dart';

part 'scoreboard_event.dart';
part 'scoreboard_state.dart';

@injectable
class ScoreboardBloc extends Bloc<ScoreboardEvent, ScoreboardState> {
  final ScoreboardRepository repository;
  late ScoringLogic _scoringLogic;

  ScoreboardBloc(this.repository) : super(const ScoreboardState()) {
    on<InitializeScoreboard>(_onInitializeScoreboard);
    on<IncrementScoreA>(_onIncrementScoreA);
    on<IncrementScoreB>(_onIncrementScoreB);
    on<DecrementScoreA>(_onDecrementScoreA);
    on<DecrementScoreB>(_onDecrementScoreB);
    on<UndoLastAction>(_onUndoLastAction);
    on<ResetMatch>(_onResetMatch);
    on<ToggleTimer>(_onToggleTimer);
    on<TimerTick>(_onTimerTick);
    on<StartNextPeriod>(_onStartNextPeriod);
    on<FinishMatch>(_onFinishMatch);
    on<SaveMatchRequested>(_onSaveMatchRequested);
  }

  void _onInitializeScoreboard(
    InitializeScoreboard event,
    Emitter<ScoreboardState> emit,
  ) {
    // Priority: Explicit config -> Default factory config
    final config = event.config ?? MatchConfiguration.forSport(event.sportType);
    _scoringLogic = ScoringLogic(config);

    emit(ScoreboardState(config: config));
  }

  void _onIncrementScoreA(
    IncrementScoreA event,
    Emitter<ScoreboardState> emit,
  ) {
    if (state.isMatchFinished || state.isPeriodFinished) return;
    _saveStateForUndo(emit);
    _processScore(emit, state.scoreA + 1, state.scoreB);
  }

  void _onIncrementScoreB(
    IncrementScoreB event,
    Emitter<ScoreboardState> emit,
  ) {
    if (state.isMatchFinished || state.isPeriodFinished) return;
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
        // Start Next Set (Points based always auto-advances to next set state?
        // Or should we wait for user confirmation?
        // Existing logic was auto-advance. Let's keep it but maybe pause?)
        // Design: "End of Period Dialog" is for time-based.
        // For points based, usually we switch sides.
        // For now, let's just reset scores and increment set.
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

  void _onTimerTick(TimerTick event, Emitter<ScoreboardState> emit) {
    if (state.isMatchFinished ||
        state.isPeriodFinished ||
        state.isTimerPaused) {
      return;
    }

    if (_scoringLogic.shouldFinishPeriodByTime(event.secondsElapsed)) {
      // Pause timer and mark period as finished to trigger UI dialog
      emit(state.copyWith(isTimerPaused: true, isPeriodFinished: true));
    }
  }

  void _onStartNextPeriod(
    StartNextPeriod event,
    Emitter<ScoreboardState> emit,
  ) {
    _saveStateForUndo(emit);
    // Finish current period/set logic for TimeBased
    if (state.isTimed) {
      final finishedPeriod = MatchSet(
        scoreA: state.scoreA,
        scoreB: state.scoreB,
      );
      final newHistory = List<MatchSet>.from(state.historySets)
        ..add(finishedPeriod);

      // Check if match finished (e.g. 2nd half done)
      // Note: scoring_logic.shouldFinishMatch checks history length.
      if (_scoringLogic.shouldFinishMatch(
        newHistory,
        state.scoreA,
        state.scoreB,
      )) {
        emit(
          state.copyWith(
            historySets: newHistory,
            isMatchFinished: true,
            isPeriodFinished: false,
            winner: _scoringLogic.getWinner(
              newHistory,
              state.scoreA,
              state.scoreB,
            ),
          ),
        );
      } else {
        // Next period
        // Usually in Futsal we KEEP the score, but period count increases.
        // Wait, MatchSet implies "Score for that set".
        // In Futsal/Football, the score is cumulative.
        // But `MatchSet` structure suggests discrete sets.
        // If I save "Set 1: 1-0", "Set 2: 2-1", does Set 2 mean "Goals in 2nd half" or "Total score"?
        // Standard scoreboard usually keeps total score visible.
        // If I reset score to 0, it's weird for football.
        // BUT, `_processScore` (points based) resets to 0.

        // Let's check `MatchResult` and `MatchSet`.
        // If I want cumulative score, I should probably NOT reset scoreA/scoreB for time-based sports.
        // But `historySets` needs to store something.
        // Maybe store the snapshot of the score at that period?

        // DECISION: For TimeBased, we DO NOT reset scoreA/scoreB.
        // We store the *cumulative* score in history for reference?
        // Or store the delta?
        // Let's store the cumulative score in history for simplicity,
        // or store the score at the end of the period.

        emit(
          state.copyWith(
            // scoreA: 0, // DON'T RESET for TimeBased
            // scoreB: 0,
            currentSet: state.currentSet + 1,
            historySets: newHistory,
            isPeriodFinished: false, // Reset flag
            isTimerPaused: true, // Keep paused until user starts
          ),
        );
      }
    }
  }

  void _onFinishMatch(FinishMatch event, Emitter<ScoreboardState> emit) {
    final finishedPeriod = MatchSet(scoreA: state.scoreA, scoreB: state.scoreB);
    final newHistory = List<MatchSet>.from(state.historySets)
      ..add(finishedPeriod);

    emit(
      state.copyWith(
        historySets: newHistory,
        isMatchFinished: true,
        isPeriodFinished: false,
        winner: _scoringLogic.getWinner(newHistory, state.scoreA, state.scoreB),
      ),
    );
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
    // Re-initialize with same config
    emit(ScoreboardState(config: state.config));
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
