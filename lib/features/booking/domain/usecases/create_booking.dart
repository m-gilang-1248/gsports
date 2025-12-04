import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class CreateBooking implements UseCase<String, CreateBookingParams> {
  final BookingRepository repository;

  CreateBooking(this.repository);

  @override
  Future<Either<Failure, String>> call(CreateBookingParams params) async {
    return await repository.createBooking(params.booking);
  }
}

class CreateBookingParams {
  final Booking booking;

  const CreateBookingParams({required this.booking});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreateBookingParams && other.booking == booking;
  }

  @override
  int get hashCode => booking.hashCode;
}
