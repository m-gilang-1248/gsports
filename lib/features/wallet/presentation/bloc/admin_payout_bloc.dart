import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/usecases/usecase.dart';
import '../../domain/usecases/get_all_pending_payouts.dart';
import '../../domain/usecases/update_transaction_status.dart';
import 'admin_payout_event.dart';
import 'admin_payout_state.dart';

@injectable
class AdminPayoutBloc extends Bloc<AdminPayoutEvent, AdminPayoutState> {
  final GetAllPendingPayouts getAllPendingPayouts;
  final UpdateTransactionStatus updateTransactionStatus;

  AdminPayoutBloc({
    required this.getAllPendingPayouts,
    required this.updateTransactionStatus,
  }) : super(AdminPayoutInitial()) {
    on<FetchAllPendingPayouts>(_onFetchAllPendingPayouts);
    on<UpdatePayoutStatus>(_onUpdatePayoutStatus);
  }

  Future<void> _onFetchAllPendingPayouts(
    FetchAllPendingPayouts event,
    Emitter<AdminPayoutState> emit,
  ) async {
    emit(AdminPayoutLoading());
    final result = await getAllPendingPayouts(NoParams());
    result.fold(
      (failure) => emit(AdminPayoutError(failure.message)),
      (payouts) => emit(AdminPayoutLoaded(payouts)),
    );
  }

  Future<void> _onUpdatePayoutStatus(
    UpdatePayoutStatus event,
    Emitter<AdminPayoutState> emit,
  ) async {
    emit(AdminPayoutActionInProgress());
    final result = await updateTransactionStatus(
      event.transactionId,
      event.status,
    );
    result.fold((failure) => emit(AdminPayoutError(failure.message)), (_) {
      emit(AdminPayoutActionSuccess('Berhasil memperbarui status penarikan'));
      add(FetchAllPendingPayouts());
    });
  }
}
