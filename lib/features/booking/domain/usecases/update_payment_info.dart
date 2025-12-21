import 'package:fpdart/fpdart.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/booking_repository.dart';

@lazySingleton
class UpdatePaymentInfo implements UseCase<void, UpdatePaymentInfoParams> {
  final BookingRepository repository;

  UpdatePaymentInfo(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdatePaymentInfoParams params) async {
    return await repository.updatePaymentInfo(
      params.bookingId,
      params.paymentUrl,
      params.orderId,
    );
  }
}

class UpdatePaymentInfoParams extends Equatable {
  final String bookingId;
  final String paymentUrl;
  final String orderId;

  const UpdatePaymentInfoParams({
    required this.bookingId,
    required this.paymentUrl,
    required this.orderId,
  });

  @override
  List<Object?> get props => [bookingId, paymentUrl, orderId];
}
