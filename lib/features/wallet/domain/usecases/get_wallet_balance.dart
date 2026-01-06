import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/failures.dart';
import '../repositories/transaction_repository.dart';

@lazySingleton
class GetWalletBalance {
  final TransactionRepository repository;

  GetWalletBalance(this.repository);

  Future<Either<Failure, int>> call(String userId) async {
    final result = await repository.getTransactionsByUserId(userId);
    return result.fold(
      (failure) => Left(failure),
      (transactions) {
        // Balance = Completed (Revenue & Payouts) + Pending Payouts
        final balance = transactions
            .where((t) => t.status == 'completed' || (t.status == 'pending' && t.type == 'payout'))
            .fold<int>(0, (sum, t) => sum + t.amount);
        return Right(balance);
      },
    );
  }
}
