import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class FetchProfile extends ProfileEvent {}

class UpdateProfileRequested extends ProfileEvent {
  final String? displayName;
  final String? phoneNumber;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountHolder;
  final File? imageFile;

  const UpdateProfileRequested({
    this.displayName,
    this.phoneNumber,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
    displayName,
    phoneNumber,
    bankName,
    bankAccountNumber,
    bankAccountHolder,
    imageFile,
  ];
}
