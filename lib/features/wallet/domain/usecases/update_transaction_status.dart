import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class UpdateTransactionStatus {
  final TransactionRepository repository;

  UpdateTransactionStatus(this.repository);

  Future<Either<Failure, void>> call(
    String transactionId,
    String status,
  ) async {
    return await repository.updateTransactionStatus(transactionId, status);
  }
}
