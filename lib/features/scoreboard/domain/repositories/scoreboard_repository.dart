import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import '../entities/match_result.dart';

abstract class ScoreboardRepository {
  Future<Either<Failure, void>> saveMatch(MatchResult match);
  Future<Either<Failure, List<MatchResult>>> getMatchesByBooking(
    String bookingId,
  );
  Future<Either<Failure, List<MatchResult>>> getMatchesByUser(String userId);
}
