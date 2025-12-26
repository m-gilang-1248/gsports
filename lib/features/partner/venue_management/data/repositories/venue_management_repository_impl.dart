import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/partner/venue_management/data/datasources/venue_management_remote_data_source.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';
import 'package:gsports/features/venue/data/models/venue_model.dart';
import 'package:gsports/features/venue/data/models/court_model.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';

@Injectable(as: VenueManagementRepository)
class VenueManagementRepositoryImpl implements VenueManagementRepository {
  final VenueManagementRemoteDataSource remoteDataSource;

  VenueManagementRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Venue>>> getMyVenues(String ownerId) async {
    try {
      final venues = await remoteDataSource.getMyVenues(ownerId);
      return Right(venues);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createVenue(
    Venue venue,
    List<File> images,
  ) async {
    try {
      final venueModel = VenueModel(
        id: '',
        ownerId: venue.ownerId,
        name: venue.name,
        description: venue.description,
        address: venue.address,
        city: venue.city,
        location: venue.location,
        facilities: venue.facilities,
        photos: const [],
        rating: 0.0,
        minPrice: venue.minPrice,
        operatingHours: venue.operatingHours,
      );
      await remoteDataSource.createVenue(venueModel, images);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateVenue(
    Venue venue, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  }) async {
    try {
      final venueModel = VenueModel(
        id: venue.id,
        ownerId: venue.ownerId,
        name: venue.name,
        description: venue.description,
        address: venue.address,
        city: venue.city,
        location: venue.location,
        facilities: venue.facilities,
        photos: venue.photos,
        rating: venue.rating,
        minPrice: venue.minPrice,
        operatingHours: venue.operatingHours,
      );
      await remoteDataSource.updateVenue(
        venueModel,
        newImages: newImages,
        removedImageUrls: removedImageUrls,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteVenue(String venueId) async {
    try {
      await remoteDataSource.deleteVenue(venueId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Court>>> getVenueCourts(String venueId) async {
    try {
      final courts = await remoteDataSource.getVenueCourts(venueId);
      return Right(courts);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCourt(String venueId, Court court) async {
    try {
      final courtModel = CourtModel(
        id: court.id,
        name: court.name,
        sportType: court.sportType,
        hourlyPrice: court.hourlyPrice,
        isActive: court.isActive,
      );
      await remoteDataSource.addCourt(venueId, courtModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCourt(String venueId, Court court) async {
    try {
      final courtModel = CourtModel(
        id: court.id,
        name: court.name,
        sportType: court.sportType,
        hourlyPrice: court.hourlyPrice,
        isActive: court.isActive,
      );
      await remoteDataSource.updateCourt(venueId, courtModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourt(
    String venueId,
    String courtId,
  ) async {
    try {
      await remoteDataSource.deleteCourt(venueId, courtId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
