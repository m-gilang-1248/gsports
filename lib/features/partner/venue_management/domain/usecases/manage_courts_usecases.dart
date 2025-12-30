import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';

@lazySingleton
class GetManagedVenueCourts implements UseCase<List<Court>, String> {
  final VenueManagementRepository repository;

  GetManagedVenueCourts(this.repository);

  @override
  Future<Either<Failure, List<Court>>> call(String venueId) async {
    return await repository.getVenueCourts(venueId);
  }
}

@lazySingleton
class AddCourt implements UseCase<void, AddCourtParams> {
  final VenueManagementRepository repository;

  AddCourt(this.repository);

  @override
  Future<Either<Failure, void>> call(AddCourtParams params) async {
    return await repository.addCourt(
      params.venueId,
      params.court,
      params.images,
    );
  }
}

class AddCourtParams {
  final String venueId;
  final Court court;
  final List<File> images;

  AddCourtParams(this.venueId, this.court, this.images);
}

@lazySingleton
class UpdateCourt implements UseCase<void, UpdateCourtParams> {
  final VenueManagementRepository repository;

  UpdateCourt(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateCourtParams params) async {
    return await repository.updateCourt(
      params.venueId,
      params.court,
      newImages: params.newImages,
      removedImageUrls: params.removedImageUrls,
    );
  }
}

class UpdateCourtParams {
  final String venueId;
  final Court court;
  final List<File>? newImages;
  final List<String>? removedImageUrls;

  UpdateCourtParams(
    this.venueId,
    this.court, {
    this.newImages,
    this.removedImageUrls,
  });
}

@lazySingleton
class DeleteCourt implements UseCase<void, DeleteCourtParams> {
  final VenueManagementRepository repository;

  DeleteCourt(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteCourtParams params) async {
    return await repository.deleteCourt(params.venueId, params.courtId);
  }
}

class DeleteCourtParams {
  final String venueId;
  final String courtId;

  DeleteCourtParams(this.venueId, this.courtId);
}
