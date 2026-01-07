import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_entity.g.dart';

@JsonSerializable()
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String role; // e.g., 'user', 'mitra', 'admin'
  final String tier; // e.g., 'free', 'premium'
  final DateTime? tierExpiryDate;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountHolder;
  final int walletBalance;
  final DateTime createdAt;
  final ScoreboardUsage scoreboardUsage;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    required this.tier,
    this.tierExpiryDate,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.walletBalance = 0,
    required this.createdAt,
    this.scoreboardUsage = const ScoreboardUsage(
      count: 0,
      lastResetMonth: 1,
      lastResetYear: 2026,
    ),
  });

  bool get isPremium => tier == 'premium';

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);

  Map<String, dynamic> toJson() => _$UserEntityToJson(this);

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    phoneNumber,
    photoUrl,
    role,
    tier,
    tierExpiryDate,
    bankName,
    bankAccountNumber,
    bankAccountHolder,
    walletBalance,
    createdAt,
    scoreboardUsage,
  ];
}

@JsonSerializable()
class ScoreboardUsage extends Equatable {
  final int count;
  final int lastResetMonth;
  final int lastResetYear;

  const ScoreboardUsage({
    required this.count,
    required this.lastResetMonth,
    required this.lastResetYear,
  });

  factory ScoreboardUsage.fromJson(Map<String, dynamic> json) =>
      _$ScoreboardUsageFromJson(json);

  Map<String, dynamic> toJson() => _$ScoreboardUsageToJson(this);

  @override
  List<Object?> get props => [count, lastResetMonth, lastResetYear];
}
