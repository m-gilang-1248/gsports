import 'package:equatable/equatable.dart';

enum ScoringType { pointsBased, timeBased }

class MatchConfiguration extends Equatable {
  final String sportType;
  final ScoringType scoringType;

  // Time-Based Settings
  final int durationPerPeriodSeconds;
  final int numberOfPeriods;
  final bool autoStopTimer;

  // Points-Based Settings
  final int winningScorePerSet;
  final int winningSetsNeeded;
  final bool deuceEnabled;
  final int maxScorePerSet; // e.g., 30 for Badminton

  const MatchConfiguration({
    required this.sportType,
    required this.scoringType,
    this.durationPerPeriodSeconds = 0,
    this.numberOfPeriods = 1,
    this.autoStopTimer = false,
    this.winningScorePerSet = 21,
    this.winningSetsNeeded = 2,
    this.deuceEnabled = false,
    this.maxScorePerSet = 999,
  });

  // Factory methods for default configurations
  factory MatchConfiguration.forSport(String sportId) {
    switch (sportId.toLowerCase()) {
      case 'futsal':
        return const MatchConfiguration(
          sportType: 'futsal',
          scoringType: ScoringType.timeBased,
          numberOfPeriods: 2,
          durationPerPeriodSeconds: 1200, // 20 mins
          autoStopTimer: true,
        );
      case 'mini_soccer':
        return const MatchConfiguration(
          sportType: 'mini_soccer',
          scoringType: ScoringType.timeBased,
          numberOfPeriods: 2,
          durationPerPeriodSeconds: 1500, // 25 mins
          autoStopTimer: true,
        );
      case 'football':
        return const MatchConfiguration(
          sportType: 'football',
          scoringType: ScoringType.timeBased,
          numberOfPeriods: 2,
          durationPerPeriodSeconds: 2700, // 45 mins
          autoStopTimer: true,
        );
      case 'basketball':
        return const MatchConfiguration(
          sportType: 'basketball',
          scoringType: ScoringType.timeBased,
          numberOfPeriods: 4,
          durationPerPeriodSeconds: 600, // 10 mins
          autoStopTimer: true,
        );
      case 'badminton':
        return const MatchConfiguration(
          sportType: 'badminton',
          scoringType: ScoringType.pointsBased,
          winningScorePerSet: 21,
          winningSetsNeeded: 2,
          deuceEnabled: true,
          maxScorePerSet: 30,
        );
      case 'tennis':
        return const MatchConfiguration(
          sportType: 'tennis',
          scoringType: ScoringType.pointsBased,
          winningScorePerSet: 6,
          winningSetsNeeded: 2,
          deuceEnabled: true, // Simplified
        );
      case 'table_tennis':
        return const MatchConfiguration(
          sportType: 'table_tennis',
          scoringType: ScoringType.pointsBased,
          winningScorePerSet: 11,
          winningSetsNeeded: 3,
          deuceEnabled: true,
        );
      case 'volleyball':
        return const MatchConfiguration(
          sportType: 'volleyball',
          scoringType: ScoringType.pointsBased,
          winningScorePerSet: 25,
          winningSetsNeeded: 3,
          deuceEnabled: true,
        );
      case 'padel':
        return const MatchConfiguration(
          sportType: 'padel',
          scoringType: ScoringType.pointsBased,
          winningScorePerSet: 6,
          winningSetsNeeded: 2,
        );
      default:
        // Generic / Manual
        return MatchConfiguration(
          sportType: sportId,
          scoringType: ScoringType.pointsBased,
          winningScorePerSet: 999,
          winningSetsNeeded: 1,
        );
    }
  }

  MatchConfiguration copyWith({
    String? sportType,
    ScoringType? scoringType,
    int? durationPerPeriodSeconds,
    int? numberOfPeriods,
    bool? autoStopTimer,
    int? winningScorePerSet,
    int? winningSetsNeeded,
    bool? deuceEnabled,
    int? maxScorePerSet,
  }) {
    return MatchConfiguration(
      sportType: sportType ?? this.sportType,
      scoringType: scoringType ?? this.scoringType,
      durationPerPeriodSeconds:
          durationPerPeriodSeconds ?? this.durationPerPeriodSeconds,
      numberOfPeriods: numberOfPeriods ?? this.numberOfPeriods,
      autoStopTimer: autoStopTimer ?? this.autoStopTimer,
      winningScorePerSet: winningScorePerSet ?? this.winningScorePerSet,
      winningSetsNeeded: winningSetsNeeded ?? this.winningSetsNeeded,
      deuceEnabled: deuceEnabled ?? this.deuceEnabled,
      maxScorePerSet: maxScorePerSet ?? this.maxScorePerSet,
    );
  }

  @override
  List<Object?> get props => [
    sportType,
    scoringType,
    durationPerPeriodSeconds,
    numberOfPeriods,
    autoStopTimer,
    winningScorePerSet,
    winningSetsNeeded,
    deuceEnabled,
    maxScorePerSet,
  ];
}
