import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../entities/payment_participant.dart';
import '../repositories/booking_repository.dart';

@injectable
class JoinBooking {
  final BookingRepository repository;

  JoinBooking(this.repository);

  Future<Either<Failure, String>> call(
      String splitCode, PaymentParticipant participant) async {
    return await repository.joinBooking(splitCode, participant);
  }
}
