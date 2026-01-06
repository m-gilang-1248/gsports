import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String userId;
  final String type; // 'revenue', 'payout'
  final int amount; // Positive for revenue, Negative for payout
  final String status; // 'completed', 'pending', 'rejected'
  final String referenceId; // bookingId or payoutId
  final String description;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.status,
    required this.referenceId,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    amount,
    status,
    referenceId,
    description,
    createdAt,
  ];
}
