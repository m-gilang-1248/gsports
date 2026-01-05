import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/partner/venue_management/domain/repositories/venue_management_repository.dart';
import 'package:gsports/features/venue/domain/entities/venue_holiday.dart';
import 'package:gsports/features/venue/domain/entities/court.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:uuid/uuid.dart';

@injectable
class AddAvailabilityBlock extends UseCase<void, AddAvailabilityBlockParams> {
  final VenueManagementRepository repository;

  AddAvailabilityBlock(this.repository);

  @override
  Future<Either<Failure, void>> call(AddAvailabilityBlockParams params) async {
    if (params.court != null) {
      // Add Court Maintenance Booking
      final maintenanceBooking = Booking(
        id: '', // Firestore will generate
        userId: 'system_maintenance',
        venueId: params.venueId,
        courtId: params.court!.id,
        sportType: params.court!.sportType,
        date: DateTime(params.date.year, params.date.month, params.date.day),
        startTime: DateTime(
          params.date.year,
          params.date.month,
          params.date.day,
          0,
          0,
        ),
        endTime: DateTime(
          params.date.year,
          params.date.month,
          params.date.day,
          23,
          59,
        ),
        durationHours: 24,
        totalPrice: 0,
        status: 'maintenance',
        paymentStatus: 'paid', // Status bypass
        venueName: params.venueName,
        courtName: params.court!.name,
        createdAt: DateTime.now(),
      );
      return await repository.addMaintenanceBooking(maintenanceBooking);
    } else {
      // Add Venue Holiday
      final holiday = VenueHoliday(
        id: const Uuid().v4(),
        name: 'Libur Toko',
        startDate: DateTime(
          params.date.year,
          params.date.month,
          params.date.day,
          0,
          0,
        ),
        endDate: DateTime(
          params.date.year,
          params.date.month,
          params.date.day,
          23,
          59,
        ),
      );
      return await repository.addVenueHoliday(params.venueId, holiday);
    }
  }
}

class AddAvailabilityBlockParams {
  final String venueId;
  final String venueName;
  final Court? court;
  final DateTime date;

  AddAvailabilityBlockParams({
    required this.venueId,
    required this.venueName,
    this.court,
    required this.date,
  });
}
