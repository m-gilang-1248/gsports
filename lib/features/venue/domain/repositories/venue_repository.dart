import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';

abstract class VenueRepository {
  Future<Either<Failure, List<Venue>>> getVenues();
  Future<Either<Failure, Venue>> getVenueDetail(String venueId);
  Future<Either<Failure, List<Court>>> getVenueCourts(String venueId);
}
