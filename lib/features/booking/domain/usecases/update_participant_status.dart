import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class UpdateParticipantStatus {
  final BookingRepository repository;

  UpdateParticipantStatus(this.repository);

  Future<Either<Failure, void>> call({
    required String bookingId,
    required String participantUid,
    required String newStatus,
  }) async {
    return await repository.updateParticipantStatus(
      bookingId,
      participantUid,
      newStatus,
    );
  }
}
