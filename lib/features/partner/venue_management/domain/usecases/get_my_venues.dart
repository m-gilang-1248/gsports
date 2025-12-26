import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import '../repositories/venue_management_repository.dart';

@lazySingleton
class GetMyVenues implements UseCase<List<Venue>, String> {
  final VenueManagementRepository repository;

  GetMyVenues(this.repository);

  @override
  Future<Either<Failure, List<Venue>>> call(String ownerId) {
    return repository.getMyVenues(ownerId);
  }
}
