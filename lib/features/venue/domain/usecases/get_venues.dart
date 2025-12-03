import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/repositories/venue_repository.dart';

@lazySingleton
class GetVenues implements UseCase<List<Venue>, NoParams> {
  final VenueRepository repository;

  GetVenues(this.repository);

  @override
  Future<Either<Failure, List<Venue>>> call(NoParams params) async {
    return await repository.getVenues();
  }
}
