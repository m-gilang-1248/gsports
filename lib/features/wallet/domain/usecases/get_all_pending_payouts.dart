import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class GetAllPendingPayouts
    implements UseCase<List<TransactionEntity>, NoParams> {
  final TransactionRepository repository;

  GetAllPendingPayouts(this.repository);

  @override
  Future<Either<Failure, List<TransactionEntity>>> call(NoParams params) async {
    return await repository.getAllPendingPayouts();
  }
}
