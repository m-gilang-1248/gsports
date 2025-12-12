import 'package:equatable/equatable.dart';

class PaymentParticipant extends Equatable {
  final String? uid;
  final String name;
  final String status; // 'host' | 'joined'
  final String paymentStatusToHost; // 'pending' | 'paid'
  final String? profileUrl;

  const PaymentParticipant({
    this.uid,
    required this.name,
    required this.status,
    required this.paymentStatusToHost,
    this.profileUrl,
  });

  @override
  List<Object?> get props => [
    uid,
    name,
    status,
    paymentStatusToHost,
    profileUrl,
  ];
}
