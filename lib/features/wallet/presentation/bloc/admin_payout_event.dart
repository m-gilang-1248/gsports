import 'package:equatable/equatable.dart';

abstract class AdminPayoutEvent extends Equatable {
  const AdminPayoutEvent();

  @override
  List<Object?> get props => [];
}

class FetchAllPendingPayouts extends AdminPayoutEvent {}

class UpdatePayoutStatus extends AdminPayoutEvent {
  final String transactionId;
  final String status; // 'completed', 'rejected'

  const UpdatePayoutStatus({required this.transactionId, required this.status});

  @override
  List<Object?> get props => [transactionId, status];
}
