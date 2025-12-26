import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../repositories/venue_management_repository.dart';

@lazySingleton
class DeleteVenue implements UseCase<void, String> {
  final VenueManagementRepository repository;

  DeleteVenue(this.repository);

  @override
  Future<Either<Failure, void>> call(String venueId) {
    return repository.deleteVenue(venueId);
  }
}
