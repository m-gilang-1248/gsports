import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';

abstract class VenueManagementRepository {
  Future<Either<Failure, List<Venue>>> getMyVenues(String ownerId);
  Future<Either<Failure, void>> createVenue(Venue venue, List<File> images);
  Future<Either<Failure, void>> updateVenue(
    Venue venue, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  });
  Future<Either<Failure, void>> deleteVenue(String venueId);

  // Court Management
  Future<Either<Failure, List<Court>>> getVenueCourts(String venueId);
  Future<Either<Failure, void>> addCourt(
    String venueId,
    Court court,
    List<File> images,
  );
  Future<Either<Failure, void>> updateCourt(
    String venueId,
    Court court, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  });
  Future<Either<Failure, void>> deleteCourt(String venueId, String courtId);
}
