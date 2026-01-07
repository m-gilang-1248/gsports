import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:json_annotation/json_annotation.dart';

import 'package:gsports/core/constants/firebase_constants.dart';
import '../../domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.phoneNumber,
    super.photoUrl,
    required super.role,
    required super.tier,
    super.tierExpiryDate,
    super.bankName,
    super.bankAccountNumber,
    super.bankAccountHolder,
    super.walletBalance = 0,
    required super.createdAt,
    super.scoreboardUsage = const ScoreboardUsage(
      count: 0,
      lastResetMonth: 1,
      lastResetYear: 2026,
    ),
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Factory to create UserModel from Firebase Auth User and Firestore document data
  factory UserModel.fromFirebaseUser(
    auth.User firebaseUser,
    DocumentSnapshot<Map<String, dynamic>> firestoreDoc,
  ) {
    final data = firestoreDoc.data();
    final scoreboardData = data?['scoreboardUsage'] as Map<String, dynamic>?;

    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      phoneNumber: data?['phoneNumber'] as String? ?? firebaseUser.phoneNumber,
      photoUrl: firebaseUser.photoURL,
      role: data?[FirebaseConstants.userRoleField] ?? 'user',
      tier: data?[FirebaseConstants.userTierField] ?? 'free',
      tierExpiryDate:
          (data?[FirebaseConstants.userTierExpiryDateField] as Timestamp?)
              ?.toDate(),
      bankName: data?['bankName'] as String?,
      bankAccountNumber: data?['bankAccountNumber'] as String?,
      bankAccountHolder: data?['bankAccountHolder'] as String?,
      walletBalance: (data?['walletBalance'] as num?)?.toInt() ?? 0,
      createdAt:
          (data?[FirebaseConstants.userCreatedAtField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
      scoreboardUsage: scoreboardData != null
          ? ScoreboardUsage(
              count: scoreboardData['count'] as int? ?? 0,
              lastResetMonth: scoreboardData['lastResetMonth'] as int? ?? 1,
              lastResetYear: scoreboardData['lastResetYear'] as int? ?? 2026,
            )
          : const ScoreboardUsage(
              count: 0,
              lastResetMonth: 1,
              lastResetYear: 2026,
            ),
    );
  }

  // Helper to create initial user document for Firestore
  static Map<String, dynamic> toFirestoreCreateData({
    required String uid,
    required String email,
    required String displayName,
    String? phoneNumber,
    String? photoUrl,
    String role = 'user',
    String tier = 'free',
  }) {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'role': role,
      'tier': tier,
      'createdAt': FieldValue.serverTimestamp(),
      'scoreboardUsage': {
        'count': 0,
        'lastResetMonth': DateTime.now().month,
        'lastResetYear': DateTime.now().year,
      },
    };
  }
}
