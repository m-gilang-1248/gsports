import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

abstract class FavoritesRepository {
  Future<Either<Failure, bool>> isFavorite(String userId, String venueId);
  Future<Either<Failure, void>> toggleFavorite(String userId, Venue venue);
  Future<Either<Failure, List<Venue>>> getFavoriteVenues(String userId);
}
