import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/payment/domain/repositories/payment_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetTransactionStatus implements UseCase<String, String> {
  final PaymentRepository repository;

  GetTransactionStatus(this.repository);

  @override
  Future<Either<Failure, String>> call(String orderId) async {
    return await repository.getTransactionStatus(orderId);
  }
}
