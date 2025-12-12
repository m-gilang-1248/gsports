import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

@injectable
class GetBookingDetail {
  final BookingRepository repository;

  GetBookingDetail(this.repository);

  Future<Either<Failure, Booking>> call(String bookingId) async {
    return await repository.getBookingDetail(bookingId);
  }
}
