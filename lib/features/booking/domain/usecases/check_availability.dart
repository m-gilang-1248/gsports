import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

import 'package:equatable/equatable.dart';

@lazySingleton
class CheckAvailability implements UseCase<bool, CheckAvailabilityParams> {
  final BookingRepository repository;

  CheckAvailability(this.repository);

  @override
  Future<Either<Failure, bool>> call(CheckAvailabilityParams params) async {
    return await repository.checkAvailability(
      courtId: params.courtId,
      date: params.date,
      startTime: params.startTime,
      endTime: params.endTime,
    );
  }
}

class CheckAvailabilityParams with EquatableMixin {
  final String courtId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;

  const CheckAvailabilityParams({
    required this.courtId,
    required this.date,
    required this.startTime,
    required this.endTime,
  });

  @override
  List<Object> get props => [courtId, date, startTime, endTime];
}
