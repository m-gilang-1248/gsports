import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking.dart';
import '../entities/payment_participant.dart';

abstract class BookingRepository {
  Future<Either<Failure, String>> createBooking(Booking booking);
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
  Future<Either<Failure, List<Booking>>> getPartnerBookings(String ownerId);
  Stream<Either<Failure, List<Booking>>> getPartnerBookingsStream(
    String ownerId,
  );
  Future<Either<Failure, void>> generateSplitCode(String bookingId);
  Future<Either<Failure, String>> joinBooking(
    String splitCode,
    PaymentParticipant participant,
  );
  Future<Either<Failure, Booking>> getBookingDetail(String bookingId);
  Future<Either<Failure, void>> updateParticipantStatus(
    String bookingId,
    String participantUid,
    String newStatus,
  );
  Future<Either<Failure, void>> updatePaymentInfo(
    String bookingId,
    String paymentUrl,
    String orderId,
  );
}
