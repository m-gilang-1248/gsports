import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int matchesPlayed;
  final int matchesWon;
  final int winRate; // Percentage 0-100
  final int currentStreak;

  const UserStats({
    required this.matchesPlayed,
    required this.matchesWon,
    required this.winRate,
    this.currentStreak = 0,
  });

  @override
  List<Object?> get props => [
    matchesPlayed,
    matchesWon,
    winRate,
    currentStreak,
  ];
}
