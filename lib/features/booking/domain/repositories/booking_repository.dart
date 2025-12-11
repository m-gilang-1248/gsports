import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import '../entities/booking.dart';

abstract class BookingRepository {
  Future<Either<Failure, String>> createBooking(
    Booking booking,
  ); // Returns new Booking ID
  Future<Either<Failure, bool>> checkAvailability({
    required String courtId,
    required DateTime date,
    required DateTime startTime,
    required DateTime endTime,
  });
  Future<Either<Failure, void>> cancelBooking(String bookingId);
  Future<Either<Failure, void>> updateBookingStatus(
    String bookingId,
    String status,
  );
  Future<Either<Failure, List<Booking>>> getMyBookings(String userId);
}
