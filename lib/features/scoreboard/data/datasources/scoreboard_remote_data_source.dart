import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import '../models/match_result_model.dart';

abstract class ScoreboardRemoteDataSource {
  Future<void> saveMatch(MatchResultModel match);
  Future<List<MatchResultModel>> getMatchesByBooking(String bookingId);
  Future<List<MatchResultModel>> getMatchesByUser(String userId);
}

@LazySingleton(as: ScoreboardRemoteDataSource)
class ScoreboardRemoteDataSourceImpl implements ScoreboardRemoteDataSource {
  final FirebaseFirestore firestore;

  ScoreboardRemoteDataSourceImpl(this.firestore);

  @override
  Future<void> saveMatch(MatchResultModel match) async {
    try {
      await firestore.collection('matches').add(match.toJson());
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MatchResultModel>> getMatchesByBooking(String bookingId) async {
    try {
      final snapshot = await firestore
          .collection('matches')
          .where('bookingId', isEqualTo: bookingId)
          .orderBy('playedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MatchResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MatchResultModel>> getMatchesByUser(String userId) async {
    try {
      // Need to find matches where user is one of the players.
      // Since schema uses simple bookingId, I might need to query by participantIds if I had them in MatchResult.
      // But looking at SCHEMA.md, 'matches' has 'players' array of UIDs.
      // Wait, let's check my MatchResult entity again.
      // It DOES NOT have players array yet. I should add it to match SCHEMA.md if I want user history.
      // PRD says: players: ["uid1", "uid2"]
      final snapshot = await firestore
          .collection('matches')
          .where('players', arrayContains: userId)
          .orderBy('playedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => MatchResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
