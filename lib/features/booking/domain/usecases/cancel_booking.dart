import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/booking/domain/repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CancelBooking implements UseCase<void, String> {
  final BookingRepository repository;

  CancelBooking(this.repository);

  @override
  Future<Either<Failure, void>> call(String bookingId) async {
    return await repository.cancelBooking(bookingId);
  }
}
