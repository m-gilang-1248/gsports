import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/data/datasources/venue_remote_data_source.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/repositories/venue_repository.dart';

@Injectable(as: VenueRepository)
class VenueRepositoryImpl implements VenueRepository {
  final VenueRemoteDataSource remoteDataSource;

  VenueRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Venue>>> getVenues() async {
    try {
      final venues = await remoteDataSource.getVenues();
      return Right(venues);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch venues'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Venue>> getVenueDetail(String venueId) async {
    try {
      final venue = await remoteDataSource.getVenueDetail(venueId);
      return Right(venue);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch venue details'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Court>>> getVenueCourts(String venueId) async {
    try {
      final courts = await remoteDataSource.getVenueCourts(venueId);
      return Right(courts);
    } on FirebaseException catch (e) {
      return Left(ServerFailure(e.message ?? 'Failed to fetch venue courts'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
