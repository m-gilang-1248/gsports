import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/venue/domain/repositories/venue_repository.dart';

@lazySingleton
class GetVenueCourts implements UseCase<List<Court>, GetVenueCourtsParams> {
  final VenueRepository repository;

  GetVenueCourts(this.repository);

  @override
  Future<Either<Failure, List<Court>>> call(GetVenueCourtsParams params) async {
    return await repository.getVenueCourts(params.venueId);
  }
}

class GetVenueCourtsParams {
  final String venueId;

  const GetVenueCourtsParams({required this.venueId});
}
