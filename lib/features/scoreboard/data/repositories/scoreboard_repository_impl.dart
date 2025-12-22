import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import '../../domain/entities/match_result.dart';
import '../../domain/repositories/scoreboard_repository.dart';
import '../datasources/scoreboard_remote_data_source.dart';
import '../models/match_result_model.dart';

@Injectable(as: ScoreboardRepository)
class ScoreboardRepositoryImpl implements ScoreboardRepository {
  final ScoreboardRemoteDataSource remoteDataSource;

  ScoreboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, void>> saveMatch(MatchResult match) async {
    try {
      final matchModel = MatchResultModel.fromEntity(match);
      await remoteDataSource.saveMatch(matchModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchResult>>> getMatchesByBooking(
    String bookingId,
  ) async {
    try {
      final matchModels = await remoteDataSource.getMatchesByBooking(bookingId);
      return Right(matchModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<MatchResult>>> getMatchesByUser(
    String userId,
  ) async {
    try {
      final matchModels = await remoteDataSource.getMatchesByUser(userId);
      return Right(matchModels);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
