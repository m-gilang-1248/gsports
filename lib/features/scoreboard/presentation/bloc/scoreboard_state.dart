part of 'scoreboard_bloc.dart';

class ScoreboardState extends Equatable {
  final int scoreA;
  final int scoreB;
  final int currentSet; // 1, 2, 3
  final List<MatchSet> historySets; // Completed sets
  final bool isMatchFinished;
  final String? winner; // 'Team A' or 'Team B'
  final List<ScoreboardState> undoStack; // For undo functionality

  const ScoreboardState({
    this.scoreA = 0,
    this.scoreB = 0,
    this.currentSet = 1,
    this.historySets = const [],
    this.isMatchFinished = false,
    this.winner,
    this.undoStack = const [],
  });

  ScoreboardState copyWith({
    int? scoreA,
    int? scoreB,
    int? currentSet,
    List<MatchSet>? historySets,
    bool? isMatchFinished,
    String? winner,
    List<ScoreboardState>? undoStack,
  }) {
    return ScoreboardState(
      scoreA: scoreA ?? this.scoreA,
      scoreB: scoreB ?? this.scoreB,
      currentSet: currentSet ?? this.currentSet,
      historySets: historySets ?? this.historySets,
      isMatchFinished: isMatchFinished ?? this.isMatchFinished,
      winner: winner ?? this.winner,
      undoStack: undoStack ?? this.undoStack,
    );
  }

  @override
  List<Object?> get props => [
    scoreA,
    scoreB,
    currentSet,
    historySets,
    isMatchFinished,
    winner,
    // undoStack excluded from props to avoid circular dependency/performance issues in equality check
  ];
}
