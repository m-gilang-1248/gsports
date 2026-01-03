import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:gsports/features/scoreboard/domain/entities/match_result.dart';
import 'package:gsports/features/scoreboard/domain/repositories/scoreboard_repository.dart';
import 'package:injectable/injectable.dart';

part 'match_history_event.dart';
part 'match_history_state.dart';

@injectable
class MatchHistoryBloc extends Bloc<MatchHistoryEvent, MatchHistoryState> {
  final ScoreboardRepository repository;

  MatchHistoryBloc(this.repository) : super(const MatchHistoryState()) {
    on<LoadMatchHistory>(_onLoadMatchHistory);
    on<UpdateSportFilter>(_onUpdateSportFilter);
    on<UpdateTimeFilter>(_onUpdateTimeFilter);
  }

  Future<void> _onLoadMatchHistory(
    LoadMatchHistory event,
    Emitter<MatchHistoryState> emit,
  ) async {
    emit(state.copyWith(status: MatchHistoryStatus.loading));
    final result = await repository.getMatchesByUser(event.userId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MatchHistoryStatus.error,
          errorMessage: failure.message,
        ),
      ),
      (matches) {
        final filtered = _applyFilters(
          matches,
          state.selectedSportId,
          state.selectedTimePreset,
          state.customDate,
        );
        emit(
          state.copyWith(
            status: MatchHistoryStatus.loaded,
            allMatches: matches,
            filteredMatches: filtered,
          ),
        );
      },
    );
  }

  void _onUpdateSportFilter(
    UpdateSportFilter event,
    Emitter<MatchHistoryState> emit,
  ) {
    final filtered = _applyFilters(
      state.allMatches,
      event.sportId,
      state.selectedTimePreset,
      state.customDate,
    );
    emit(
      state.copyWith(
        selectedSportId: event.sportId,
        clearSportId: event.sportId == null,
        filteredMatches: filtered,
      ),
    );
  }

  void _onUpdateTimeFilter(
    UpdateTimeFilter event,
    Emitter<MatchHistoryState> emit,
  ) {
    final filtered = _applyFilters(
      state.allMatches,
      state.selectedSportId,
      event.preset,
      event.customDate,
    );
    emit(
      state.copyWith(
        selectedTimePreset: event.preset,
        customDate: event.customDate,
        filteredMatches: filtered,
      ),
    );
  }

  List<MatchResult> _applyFilters(
    List<MatchResult> matches,
    String? sportId,
    TimeFilterPreset timePreset,
    DateTime? customDate,
  ) {
    return matches.where((match) {
      // 1. Sport Filter
      if (sportId != null &&
          match.sportType.toLowerCase() != sportId.toLowerCase()) {
        return false;
      }

      // 2. Time Filter
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (timePreset) {
        case TimeFilterPreset.all:
          return true;
        case TimeFilterPreset.thisWeek:
          final weekAgo = today.subtract(const Duration(days: 7));
          return match.playedAt.isAfter(weekAgo);
        case TimeFilterPreset.thisMonth:
          final monthAgo = DateTime(today.year, today.month - 1, today.day);
          return match.playedAt.isAfter(monthAgo);
        case TimeFilterPreset.customDate:
          if (customDate == null) return true;
          return match.playedAt.year == customDate.year &&
              match.playedAt.month == customDate.month &&
              match.playedAt.day == customDate.day;
      }
    }).toList()..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }
}
