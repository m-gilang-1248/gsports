import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/booking/domain/repositories/booking_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class UpdateBookingStatus implements UseCase<void, UpdateBookingStatusParams> {
  final BookingRepository repository;

  UpdateBookingStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateBookingStatusParams params) async {
    return await repository.updateBookingStatus(
      params.bookingId,
      params.status,
    );
  }
}

class UpdateBookingStatusParams extends Equatable {
  final String bookingId;
  final String status;

  const UpdateBookingStatusParams({
    required this.bookingId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookingId, status];
}
