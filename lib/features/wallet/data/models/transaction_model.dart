import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.amount,
    required super.status,
    required super.referenceId,
    required super.description,
    required super.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] as String,
      type: data['type'] as String,
      amount: (data['amount'] as num).toInt(),
      status: data['status'] as String,
      referenceId: data['referenceId'] as String,
      description: data['description'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  static Map<String, dynamic> toFirestoreData(TransactionEntity transaction) {
    return {
      'userId': transaction.userId,
      'type': transaction.type,
      'amount': transaction.amount,
      'status': transaction.status,
      'referenceId': transaction.referenceId,
      'description': transaction.description,
      'createdAt': Timestamp.fromDate(transaction.createdAt),
    };
  }
}
