import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class GetTransactions implements UseCase<List<TransactionEntity>, String> {
  final TransactionRepository repository;

  GetTransactions(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(String userId) async {
    return await repository.getTransactionsByUserId(userId);
  }
}
