import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

@lazySingleton
class ToggleFavorite implements UseCase<void, ToggleFavoriteParams> {
  final FavoritesRepository repository;

  ToggleFavorite(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleFavoriteParams params) async {
    return await repository.toggleFavorite(params.userId, params.venue);
  }
}

class ToggleFavoriteParams {
  final String userId;
  final Venue venue;

  ToggleFavoriteParams(this.userId, this.venue);
}

@lazySingleton
class CheckIsFavorite implements UseCase<bool, CheckIsFavoriteParams> {
  final FavoritesRepository repository;

  CheckIsFavorite(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckIsFavoriteParams params) async {
    return await repository.isFavorite(params.userId, params.venueId);
  }
}

class CheckIsFavoriteParams {
  final String userId;
  final String venueId;

  CheckIsFavoriteParams(this.userId, this.venueId);
}

@lazySingleton
class GetFavoriteVenues implements UseCase<List<Venue>, String> {
  final FavoritesRepository repository;

  GetFavoriteVenues(this.repository);

  @override
  Future<Either<Failure, List<Venue>>> call(String userId) async {
    return await repository.getFavoriteVenues(userId);
  }
}
