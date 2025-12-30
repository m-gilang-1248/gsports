import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/favorites/data/datasources/favorites_remote_data_source.dart';
import 'package:gsports/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

@Injectable(as: FavoritesRepository)
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesRemoteDataSource remoteDataSource;

  FavoritesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, bool>> isFavorite(
    String userId,
    String venueId,
  ) async {
    try {
      final result = await remoteDataSource.isFavorite(userId, venueId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(
    String userId,
    Venue venue,
  ) async {
    try {
      await remoteDataSource.toggleFavorite(userId, venue);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Venue>>> getFavoriteVenues(String userId) async {
    try {
      final result = await remoteDataSource.getFavoriteVenues(userId);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
