part of 'match_history_bloc.dart';

enum TimeFilterPreset { all, thisWeek, thisMonth, customDate }

abstract class MatchHistoryEvent extends Equatable {
  const MatchHistoryEvent();

  @override
  List<Object?> get props => [];
}

class LoadMatchHistory extends MatchHistoryEvent {
  final String userId;
  const LoadMatchHistory(this.userId);

  @override
  List<Object?> get props => [userId];
}

class UpdateSportFilter extends MatchHistoryEvent {
  final String? sportId;
  const UpdateSportFilter(this.sportId);

  @override
  List<Object?> get props => [sportId];
}

class UpdateTimeFilter extends MatchHistoryEvent {
  final TimeFilterPreset preset;
  final DateTime? customDate;

  const UpdateTimeFilter({required this.preset, this.customDate});

  @override
  List<Object?> get props => [preset, customDate];
}
