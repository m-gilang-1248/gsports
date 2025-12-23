// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  uid: json['uid'] as String,
  email: json['email'] as String,
  displayName: json['displayName'] as String,
  phoneNumber: json['phoneNumber'] as String?,
  photoUrl: json['photoUrl'] as String?,
  role: json['role'] as String,
  tier: json['tier'] as String,
  tierExpiryDate: json['tierExpiryDate'] == null
      ? null
      : DateTime.parse(json['tierExpiryDate'] as String),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'uid': instance.uid,
  'email': instance.email,
  'displayName': instance.displayName,
  'phoneNumber': instance.phoneNumber,
  'photoUrl': instance.photoUrl,
  'role': instance.role,
  'tier': instance.tier,
  'tierExpiryDate': instance.tierExpiryDate?.toIso8601String(),
  'createdAt': instance.createdAt.toIso8601String(),
};
