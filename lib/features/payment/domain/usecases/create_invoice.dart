import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/payment_info.dart';
import '../repositories/payment_repository.dart';

@lazySingleton
class CreateInvoice implements UseCase<PaymentInfo, CreateInvoiceParams> {
  final PaymentRepository repository;

  CreateInvoice(this.repository);

  @override
  Future<Either<Failure, PaymentInfo>> call(CreateInvoiceParams params) async {
    return repository.createInvoice(
      orderId: params.orderId,
      amount: params.amount,
    );
  }
}

class CreateInvoiceParams extends Equatable {
  final String orderId;
  final int amount;

  const CreateInvoiceParams({
    required this.orderId,
    required this.amount,
  });

  @override
  List<Object?> get props => [orderId, amount];
}
