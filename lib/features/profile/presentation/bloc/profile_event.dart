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
  final File? imageFile;

  const UpdateProfileRequested({
    this.displayName,
    this.phoneNumber,
    this.imageFile,
  });

  @override
  List<Object?> get props => [displayName, phoneNumber, imageFile];
}
