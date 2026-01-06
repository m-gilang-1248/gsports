import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionRepository {
  Future<Either<Failure, String>> createTransaction(
    TransactionEntity transaction,
  );
  Future<Either<Failure, List<TransactionEntity>>> getTransactionsByUserId(
    String userId,
  );
  Future<Either<Failure, List<TransactionEntity>>> getAllPendingPayouts();
  Future<Either<Failure, void>> updateTransactionStatus(
    String transactionId,
    String status,
  );
}
