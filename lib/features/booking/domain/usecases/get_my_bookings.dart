import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/booking/domain/entities/booking.dart';
import 'package:gsports/features/booking/domain/repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetMyBookings implements UseCase<List<Booking>, String> {
  final BookingRepository repository;

  GetMyBookings(this.repository);

  @override
  Future<Either<Failure, List<Booking>>> call(String params) async {
    return await repository.getMyBookings(params);
  }
}
