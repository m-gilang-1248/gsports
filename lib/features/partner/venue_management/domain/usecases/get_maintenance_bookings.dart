import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';

@injectable
class GetMaintenanceBookings {
  final VenueManagementRepository repository;

  GetMaintenanceBookings(this.repository);

  Future<Either<Failure, List<Booking>>> call(
    String venueId,
    DateTime startDate,
    DateTime endDate,
  ) {
    return repository.getMaintenanceBookings(venueId, startDate, endDate);
  }
}
