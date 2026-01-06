import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/get_wallet_balance.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

@injectable
class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletBalance getWalletBalance;
  final GetTransactions getTransactions;
  final CreateTransaction createTransaction;

  WalletBloc({
    required this.getWalletBalance,
    required this.getTransactions,
    required this.createTransaction,
  }) : super(WalletInitial()) {
    on<FetchWalletData>(_onFetchWalletData);
    on<RequestPayout>(_onRequestPayout);
  }

  Future<void> _onFetchWalletData(
    FetchWalletData event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletLoading());

    final balanceResult = await getWalletBalance(event.userId);
    final transactionsResult = await getTransactions(event.userId);

    balanceResult.fold(
      (failure) => emit(WalletError(failure.message)),
      (balance) {
        transactionsResult.fold(
          (failure) => emit(WalletError(failure.message)),
          (transactions) => emit(
            WalletLoaded(balance: balance, transactions: transactions),
          ),
        );
      },
    );
  }

  Future<void> _onRequestPayout(
    RequestPayout event,
    Emitter<WalletState> emit,
  ) async {
    emit(WalletPayoutProcessing());

    final transaction = TransactionEntity(
      id: '', // Firestore will generate
      userId: event.userId,
      type: 'payout',
      amount: -event.amount, // Negative for payout
      status: 'pending',
      referenceId: 'PO-${DateTime.now().millisecondsSinceEpoch}',
      description: 'Penarikan Dana ke ${event.bankDetails}',
      createdAt: DateTime.now(),
    );

    final result = await createTransaction(transaction);

    result.fold((failure) => emit(WalletError(failure.message)), (_) {
      emit(WalletPayoutSuccess());
      // Refresh wallet data
      add(FetchWalletData(event.userId));
    });
  }
}
