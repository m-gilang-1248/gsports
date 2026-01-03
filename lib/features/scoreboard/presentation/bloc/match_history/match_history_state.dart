part of 'match_history_bloc.dart';

enum MatchHistoryStatus { initial, loading, loaded, error }

class MatchHistoryState extends Equatable {
  final MatchHistoryStatus status;
  final List<MatchResult> allMatches;
  final List<MatchResult> filteredMatches;
  final String? selectedSportId;
  final TimeFilterPreset selectedTimePreset;
  final DateTime? customDate;
  final String? errorMessage;

  const MatchHistoryState({
    this.status = MatchHistoryStatus.initial,
    this.allMatches = const [],
    this.filteredMatches = const [],
    this.selectedSportId,
    this.selectedTimePreset = TimeFilterPreset.all,
    this.customDate,
    this.errorMessage,
  });

  MatchHistoryState copyWith({
    MatchHistoryStatus? status,
    List<MatchResult>? allMatches,
    List<MatchResult>? filteredMatches,
    String? selectedSportId,
    bool clearSportId = false,
    TimeFilterPreset? selectedTimePreset,
    DateTime? customDate,
    String? errorMessage,
  }) {
    return MatchHistoryState(
      status: status ?? this.status,
      allMatches: allMatches ?? this.allMatches,
      filteredMatches: filteredMatches ?? this.filteredMatches,
      selectedSportId: clearSportId
          ? null
          : (selectedSportId ?? this.selectedSportId),
      selectedTimePreset: selectedTimePreset ?? this.selectedTimePreset,
      customDate: customDate ?? this.customDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // Helper because we want to be able to set selectedSportId to null
  MatchHistoryState copyWithSelectedSport(String? sportId) {
    return MatchHistoryState(
      status: status,
      allMatches: allMatches,
      filteredMatches: filteredMatches,
      selectedSportId: sportId,
      selectedTimePreset: selectedTimePreset,
      customDate: customDate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    allMatches,
    filteredMatches,
    selectedSportId,
    selectedTimePreset,
    customDate,
    errorMessage,
  ];
}
