import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';
import 'package:gsports/features/venue/domain/entities/venue_holiday.dart';

@injectable
class RemoveAvailabilityBlock extends UseCase<void, RemoveAvailabilityBlockParams> {
  final VenueManagementRepository repository;

  RemoveAvailabilityBlock(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveAvailabilityBlockParams params) async {
    if (params.type == AvailabilityBlockType.maintenance) {
      if (params.bookingId == null) {
        return const Left(ServerFailure('Booking ID is required for maintenance deletion'));
      }
      return await repository.removeMaintenanceBooking(params.bookingId!);
    } else {
      if (params.venueId == null || params.holiday == null) {
        return const Left(ServerFailure('Venue ID and Holiday are required for holiday deletion'));
      }
      return await repository.removeVenueHoliday(params.venueId!, params.holiday!);
    }
  }
}

enum AvailabilityBlockType { holiday, maintenance }

class RemoveAvailabilityBlockParams {
  final String? venueId;
  final String? bookingId;
  final VenueHoliday? holiday;
  final AvailabilityBlockType type;

  RemoveAvailabilityBlockParams({
    this.venueId,
    this.bookingId,
    this.holiday,
    required this.type,
  });
}
