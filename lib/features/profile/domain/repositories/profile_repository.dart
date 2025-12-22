import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import '../entities/user_stats.dart';

abstract class ProfileRepository {
  Future<Either<Failure, UserStats>> getUserStats(String uid);
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    File? imageFile,
  });
}
