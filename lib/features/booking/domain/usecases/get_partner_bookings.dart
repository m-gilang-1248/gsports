import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class GetPartnerBookings implements UseCase<List<Booking>, String> {
  final BookingRepository repository;

  GetPartnerBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(String ownerId) async {
    return await repository.getPartnerBookings(ownerId);
  }

  Stream<Either<Failure, List<Booking>>> callStream(String ownerId) {
    return repository.getPartnerBookingsStream(ownerId);
  }
}
