part of 'scoreboard_bloc.dart';

class ScoreboardState extends Equatable {
  final MatchConfiguration config;
  final int scoreA;
  final int scoreB;
  final int currentSet; // 1, 2, 3 (Also acts as Period)
  final List<MatchSet> historySets; // Completed sets/periods
  final bool isMatchFinished;
  final bool isPeriodFinished; // New: To show dialog between periods
  final String? winner; // 'Team A' or 'Team B'
  final List<ScoreboardState> undoStack; // For undo functionality
  final bool isTimerPaused;

  // Save states
  final bool isSaving;
  final bool saveSuccess;
  final String? errorMessage;

  const ScoreboardState({
    this.config = const MatchConfiguration(
      sportType: 'generic',
      scoringType: ScoringType.pointsBased,
    ),
    this.scoreA = 0,
    this.scoreB = 0,
    this.currentSet = 1,
    this.historySets = const [],
    this.isMatchFinished = false,
    this.isPeriodFinished = false,
    this.winner,
    this.undoStack = const [],
    this.isTimerPaused = false,
    this.isSaving = false,
    this.saveSuccess = false,
    this.errorMessage,
  });

  // Convenience getters for UI
  bool get usesSets =>
      config.numberOfPeriods > 1 || config.winningSetsNeeded > 1;
  bool get isTimed => config.scoringType == ScoringType.timeBased;
  int get targetDurationMinutes =>
      (config.durationPerPeriodSeconds / 60).round();

  ScoreboardState copyWith({
    MatchConfiguration? config,
    int? scoreA,
    int? scoreB,
    int? currentSet,
    List<MatchSet>? historySets,
    bool? isMatchFinished,
    bool? isPeriodFinished,
    String? winner,
    List<ScoreboardState>? undoStack,
    bool? isTimerPaused,
    bool? isSaving,
    bool? saveSuccess,
    String? errorMessage,
  }) {
    return ScoreboardState(
      config: config ?? this.config,
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      currentSet: currentSet ?? this.currentSet,
      historySets: historySets ?? this.historySets,
      isMatchFinished: isMatchFinished ?? this.isMatchFinished,
      isPeriodFinished: isPeriodFinished ?? this.isPeriodFinished,
      winner: winner ?? this.winner,
      undoStack: undoStack ?? this.undoStack,
      isTimerPaused: isTimerPaused ?? this.isTimerPaused,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    config,
    scoreA,
    scoreB,
    currentSet,
    historySets,
    isMatchFinished,
    isPeriodFinished,
    winner,
    isTimerPaused,
    isSaving,
    saveSuccess,
    errorMessage,
  ];
}
