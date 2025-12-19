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
    super.photoUrl,
    required super.role,
    required super.tier,
    super.tierExpiryDate,
    required super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Factory to create UserModel from Firebase Auth User and Firestore document data
  factory UserModel.fromFirebaseUser(
    auth.User firebaseUser,
    DocumentSnapshot<Map<String, dynamic>> firestoreDoc,
  ) {
    final data = firestoreDoc.data();
    return UserModel(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      photoUrl: firebaseUser.photoURL,
      role: data?[FirebaseConstants.userRoleField] ?? 'user',
      tier: data?[FirebaseConstants.userTierField] ?? 'free',
      tierExpiryDate:
          (data?[FirebaseConstants.userTierExpiryDateField] as Timestamp?)
              ?.toDate(),
      createdAt:
          (data?[FirebaseConstants.userCreatedAtField] as Timestamp?)
              ?.toDate() ??
          DateTime.now(),
    );
  }

  // Helper to create initial user document for Firestore
  static Map<String, dynamic> toFirestoreCreateData({
    required String uid,
    required String email,
    required String displayName,
    String? photoUrl,
    String role = 'user',
    String tier = 'free',
  }) {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'tier': tier,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
