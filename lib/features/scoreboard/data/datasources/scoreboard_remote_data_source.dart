import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import '../models/match_result_model.dart';

abstract class ScoreboardRemoteDataSource {
  Future<void> saveMatch(MatchResultModel match);
  Future<List<MatchResultModel>> getMatchesByBooking(String bookingId);
  Future<List<MatchResultModel>> getMatchesByUser(String userId);
  Future<bool> checkScoreboardLimit(String userId);
  Future<void> incrementScoreboardUsage(String userId);
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

  @override
  Future<bool> checkScoreboardLimit(String userId) async {
    try {
      final doc = await firestore.collection('users').doc(userId).get();
      if (!doc.exists) return true;

      final data = doc.data()!;
      final tier = data['tier'] ?? 'free';
      if (tier == 'premium') return true;

      final scoreboardUsage = data['scoreboardUsage'] as Map<String, dynamic>?;
      if (scoreboardUsage == null) return true;

      final count = scoreboardUsage['count'] as int? ?? 0;
      final lastMonth = scoreboardUsage['lastResetMonth'] as int? ?? 0;
      final lastYear = scoreboardUsage['lastResetYear'] as int? ?? 0;

      final now = DateTime.now();
      if (now.month != lastMonth || now.year != lastYear) {
        return true;
      }

      return count < 5;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> incrementScoreboardUsage(String userId) async {
    try {
      final docRef = firestore.collection('users').doc(userId);
      await firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);
        if (!snapshot.exists) return;

        final data = snapshot.data()!;
        final tier = data['tier'] ?? 'free';
        if (tier == 'premium') return;

        final scoreboardUsage =
            data['scoreboardUsage'] as Map<String, dynamic>?;
        final now = DateTime.now();

        int count = 1;
        int lastMonth = now.month;
        int lastYear = now.year;

        if (scoreboardUsage != null) {
          final m = scoreboardUsage['lastResetMonth'] as int? ?? 0;
          final y = scoreboardUsage['lastResetYear'] as int? ?? 0;
          if (now.month == m && now.year == y) {
            count = (scoreboardUsage['count'] as int? ?? 0) + 1;
          }
        }

        transaction.update(docRef, {
          'scoreboardUsage': {
            'count': count,
            'lastResetMonth': lastMonth,
            'lastResetYear': lastYear,
          },
        });
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
