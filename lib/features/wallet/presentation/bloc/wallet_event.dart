import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class FetchWalletData extends WalletEvent {
  final String userId;
  const FetchWalletData(this.userId);

  @override
  List<Object?> get props => [userId];
}

class RequestPayout extends WalletEvent {
  final String userId;
  final int amount;
  final String bankDetails;

  const RequestPayout({
    required this.userId,
    required this.amount,
    required this.bankDetails,
  });

  @override
  List<Object?> get props => [userId, amount, bankDetails];
}
