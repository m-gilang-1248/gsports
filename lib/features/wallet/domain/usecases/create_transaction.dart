import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class CreateTransaction implements UseCase<String, TransactionEntity> {
  final TransactionRepository repository;

  CreateTransaction(this.repository);

  @override
  Future<Either<Failure, String>> call(TransactionEntity transaction) async {
    return await repository.createTransaction(transaction);
  }
}
