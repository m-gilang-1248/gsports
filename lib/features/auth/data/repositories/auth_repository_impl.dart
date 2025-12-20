import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

@Injectable(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, UserEntity>> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await remoteDataSource.loginWithEmailPassword(
        email: email,
        password: password,
      );
      return Right(userModel);
    } on ServerException catch (e, st) {
      debugPrint('AuthRepositoryImpl - ServerException: $e');
      return Left(ServerFailure(e.message, stackTrace: st));
    } on AuthException catch (e, st) {
      debugPrint('AuthRepositoryImpl - AuthException: $e');
      return Left(AuthFailure(e.message, stackTrace: st));
    } catch (e, st) {
      debugPrint('AuthRepositoryImpl - Unknown error during login: $e');
      return Left(ServerFailure(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
    String role = 'user',
  }) async {
    try {
      final userModel = await remoteDataSource.registerWithEmailPassword(
        email: email,
        password: password,
        displayName: displayName,
        role: role,
      );
      return Right(userModel);
    } on ServerException catch (e, st) {
      debugPrint('AuthRepositoryImpl - ServerException: $e');
      return Left(ServerFailure(e.message, stackTrace: st));
    } on AuthException catch (e, st) {
      debugPrint('AuthRepositoryImpl - AuthException: $e');
      return Left(AuthFailure(e.message, stackTrace: st));
    } catch (e, st) {
      debugPrint('AuthRepositoryImpl - Unknown error during registration: $e');
      return Left(ServerFailure(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle({String? role}) async {
    try {
      final userModel = await remoteDataSource.signInWithGoogle(role: role);
      return Right(userModel);
    } on ServerException catch (e, st) {
      debugPrint('AuthRepositoryImpl - ServerException: $e');
      return Left(ServerFailure(e.message, stackTrace: st));
    } on AuthException catch (e, st) {
      debugPrint('AuthRepositoryImpl - AuthException: $e');
      return Left(AuthFailure(e.message, stackTrace: st));
    } catch (e, st) {
      debugPrint(
        'AuthRepositoryImpl - Unknown error during Google Sign-In: $e',
      );
      return Left(ServerFailure(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } on ServerException catch (e, st) {
      debugPrint('AuthRepositoryImpl - ServerException: $e');
      return Left(ServerFailure(e.message, stackTrace: st));
    } catch (e, st) {
      debugPrint('AuthRepositoryImpl - Unknown error during logout: $e');
      return Left(ServerFailure(e.toString(), stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> checkAuthStatus() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return Right(userModel);
    } on ServerException catch (e, st) {
      debugPrint('AuthRepositoryImpl - ServerException: $e');
      return Left(ServerFailure(e.message, stackTrace: st));
    } on AuthException catch (e, st) {
      debugPrint('AuthRepositoryImpl - AuthException: $e');
      return Left(AuthFailure(e.message, stackTrace: st));
    } catch (e, st) {
      debugPrint(
        'AuthRepositoryImpl - Unknown error during checkAuthStatus: $e',
      );
      return Left(ServerFailure(e.toString(), stackTrace: st));
    }
  }
}
