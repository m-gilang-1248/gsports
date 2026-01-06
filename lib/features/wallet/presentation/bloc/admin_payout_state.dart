import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class AdminPayoutState extends Equatable {
  const AdminPayoutState();

  @override
  List<Object?> get props => [];
}

class AdminPayoutInitial extends AdminPayoutState {}

class AdminPayoutLoading extends AdminPayoutState {}

class AdminPayoutLoaded extends AdminPayoutState {
  final List<TransactionEntity> payouts;

  const AdminPayoutLoaded(this.payouts);

  @override
  List<Object?> get props => [payouts];
}

class AdminPayoutActionInProgress extends AdminPayoutState {}

class AdminPayoutActionSuccess extends AdminPayoutState {
  final String message;
  const AdminPayoutActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AdminPayoutError extends AdminPayoutState {
  final String message;
  const AdminPayoutError(this.message);

  @override
  List<Object?> get props => [message];
}
