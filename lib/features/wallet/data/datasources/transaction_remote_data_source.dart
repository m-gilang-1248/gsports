import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/constants/firebase_constants.dart';
import '../models/transaction_model.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionRemoteDataSource {
  Future<String> createTransaction(TransactionEntity transaction);
  Future<List<TransactionModel>> getTransactionsByUserId(String userId);
  Future<List<TransactionModel>> getAllPendingPayouts();
  Future<void> updateTransactionStatus(String transactionId, String status);
}

@LazySingleton(as: TransactionRemoteDataSource)
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;

  TransactionRemoteDataSourceImpl(this.firestore);

  @override
  Future<String> createTransaction(TransactionEntity transaction) async {
    final docRef = await firestore
        .collection(FirebaseConstants.transactionsCollection)
        .add(TransactionModel.toFirestoreData(transaction));
    return docRef.id;
  }

  @override
  Future<List<TransactionModel>> getTransactionsByUserId(String userId) async {
    final querySnapshot = await firestore
        .collection(FirebaseConstants.transactionsCollection)
        .where(FirebaseConstants.transactionUserIdField, isEqualTo: userId)
        .orderBy(FirebaseConstants.transactionCreatedAtField, descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<List<TransactionModel>> getAllPendingPayouts() async {
    final querySnapshot = await firestore
        .collection(FirebaseConstants.transactionsCollection)
        .where(FirebaseConstants.transactionTypeField, isEqualTo: 'payout')
        .where(FirebaseConstants.transactionStatusField, isEqualTo: 'pending')
        .orderBy(FirebaseConstants.transactionCreatedAtField, descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  @override
  Future<void> updateTransactionStatus(
    String transactionId,
    String status,
  ) async {
    await firestore
        .collection(FirebaseConstants.transactionsCollection)
        .doc(transactionId)
        .update({FirebaseConstants.transactionStatusField: status});
  }
}
