// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserEntity _$UserEntityFromJson(Map<String, dynamic> json) => UserEntity(
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
  bankName: json['bankName'] as String?,
  bankAccountNumber: json['bankAccountNumber'] as String?,
  bankAccountHolder: json['bankAccountHolder'] as String?,
  walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['createdAt'] as String),
  scoreboardUsage: json['scoreboardUsage'] == null
      ? const ScoreboardUsage(count: 0, lastResetMonth: 1, lastResetYear: 2026)
      : ScoreboardUsage.fromJson(
          json['scoreboardUsage'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$UserEntityToJson(UserEntity instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'email': instance.email,
      'displayName': instance.displayName,
      'phoneNumber': instance.phoneNumber,
      'photoUrl': instance.photoUrl,
      'role': instance.role,
      'tier': instance.tier,
      'tierExpiryDate': instance.tierExpiryDate?.toIso8601String(),
      'bankName': instance.bankName,
      'bankAccountNumber': instance.bankAccountNumber,
      'bankAccountHolder': instance.bankAccountHolder,
      'walletBalance': instance.walletBalance,
      'createdAt': instance.createdAt.toIso8601String(),
      'scoreboardUsage': instance.scoreboardUsage,
    };

ScoreboardUsage _$ScoreboardUsageFromJson(Map<String, dynamic> json) =>
    ScoreboardUsage(
      count: (json['count'] as num).toInt(),
      lastResetMonth: (json['lastResetMonth'] as num).toInt(),
      lastResetYear: (json['lastResetYear'] as num).toInt(),
    );

Map<String, dynamic> _$ScoreboardUsageToJson(ScoreboardUsage instance) =>
    <String, dynamic>{
      'count': instance.count,
      'lastResetMonth': instance.lastResetMonth,
      'lastResetYear': instance.lastResetYear,
    };
