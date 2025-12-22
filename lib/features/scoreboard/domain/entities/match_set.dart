import 'package:equatable/equatable.dart';

class MatchSet extends Equatable {
  final int scoreA;
  final int scoreB;

  const MatchSet({required this.scoreA, required this.scoreB});

  @override
  List<Object?> get props => [scoreA, scoreB];
}
