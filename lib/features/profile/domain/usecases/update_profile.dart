import 'dart:io';
import 'package:injectable/injectable.dart';
import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/core/usecases/usecase.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

@injectable
class UpdateProfile implements UseCase<UserEntity, UpdateProfileParams> {
  final ProfileRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateProfile(
      uid: params.uid,
      displayName: params.displayName,
      phoneNumber: params.phoneNumber,
      bankName: params.bankName,
      bankAccountNumber: params.bankAccountNumber,
      bankAccountHolder: params.bankAccountHolder,
      imageFile: params.imageFile,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String uid;
  final String? displayName;
  final String? phoneNumber;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankAccountHolder;
  final File? imageFile;

  const UpdateProfileParams({
    required this.uid,
    this.displayName,
    this.phoneNumber,
    this.bankName,
    this.bankAccountNumber,
    this.bankAccountHolder,
    this.imageFile,
  });

  @override
  List<Object?> get props => [
    uid,
    displayName,
    phoneNumber,
    bankName,
    bankAccountNumber,
    bankAccountHolder,
    imageFile,
  ];
}
