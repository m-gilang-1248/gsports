import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? phoneNumber;
  final String? photoUrl;
  final String role; // e.g., 'user', 'mitra', 'admin'
  final String tier; // e.g., 'free', 'premium'
  final DateTime? tierExpiryDate;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    required this.displayName,
    this.phoneNumber,
    this.photoUrl,
    required this.role,
    required this.tier,
    this.tierExpiryDate,
    required this.createdAt,
  });

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
    createdAt,
  ];
}
