import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import '../models/match_result_model.dart';

abstract class ScoreboardRemoteDataSource {
  Future<void> saveMatch(MatchResultModel match);
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
}
