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

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      amount: entity.amount,
      status: entity.status,
      referenceId: entity.referenceId,
      description: entity.description,
      createdAt: entity.createdAt,
    );
  }

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

  static Map<String, dynamic> toFirestoreData(TransactionEntity entity) {
    return {
      'userId': entity.userId,
      'type': entity.type,
      'amount': entity.amount,
      'status': entity.status,
      'referenceId': entity.referenceId,
      'description': entity.description,
      'createdAt': Timestamp.fromDate(entity.createdAt),
    };
  }
}
