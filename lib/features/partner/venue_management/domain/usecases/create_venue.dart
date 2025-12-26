import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import '../repositories/venue_management_repository.dart';

@lazySingleton
class CreateVenue {
  final VenueManagementRepository repository;

  CreateVenue(this.repository);

  Future<Either<Failure, void>> call(Venue venue, List<File> images) {
    return repository.createVenue(venue, images);
  }
}
