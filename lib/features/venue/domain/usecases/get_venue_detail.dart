import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/venue/domain/entities/venue.dart';
import 'package:gsports/features/venue/domain/repositories/venue_repository.dart';

@lazySingleton
class GetVenueDetail implements UseCase<Venue, GetVenueDetailParams> {
  final VenueRepository repository;

  GetVenueDetail(this.repository);

  @override
  Future<Either<Failure, Venue>> call(GetVenueDetailParams params) async {
    return await repository.getVenueDetail(params.venueId);
  }
}

class GetVenueDetailParams {
  final String venueId;

  const GetVenueDetailParams({required this.venueId});
}
