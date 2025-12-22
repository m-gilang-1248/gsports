import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/core/error/failures.dart';
import 'package:gsports/features/auth/domain/entities/user_entity.dart';
import 'package:gsports/features/profile/domain/entities/user_stats.dart';
import 'package:gsports/features/profile/domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';

@Injectable(as: ProfileRepository)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, UserStats>> getUserStats(String uid) async {
    try {
      final matches = await remoteDataSource.getMatchesByUser(uid);

      int totalMatches = matches.length;
      int wins = 0;

      for (final match in matches) {
        final players = match.players;
        final winner = match.winner;

        if (players.length >= 2) {
          if ((uid == players[0] && winner == 'Team A') ||
              (uid == players[1] && winner == 'Team B')) {
            wins++;
          }
        } else if (players.length == 1) {
          // Special case for solo? Or assume players[0] is Team A
          if (uid == players[0] && winner == 'Team A') {
            wins++;
          }
        }
      }

      int winRate = totalMatches > 0 ? (wins * 100 ~/ totalMatches) : 0;

      return Right(
        UserStats(
          matchesPlayed: totalMatches,
          matchesWon: wins,
          winRate: winRate,
        ),
      );
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    File? imageFile,
  }) async {
    try {
      final userModel = await remoteDataSource.updateProfile(
        uid: uid,
        displayName: displayName,
        phoneNumber: phoneNumber,
        imageFile: imageFile,
      );
      return Right(userModel);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
