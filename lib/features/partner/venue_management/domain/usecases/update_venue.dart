import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import '../repositories/venue_management_repository.dart';

@lazySingleton
class UpdateVenue {
  final VenueManagementRepository repository;

  UpdateVenue(this.repository);

  Future<Either<Failure, void>> call(
    Venue venue, {
    List<File>? newImages,
    List<String>? removedImageUrls,
  }) {
    return repository.updateVenue(
      venue,
      newImages: newImages,
      removedImageUrls: removedImageUrls,
    );
  }
}
