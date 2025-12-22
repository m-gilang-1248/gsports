import 'dart:io';
import 'package:gsports/features/auth/data/models/user_model.dart';
import 'package:gsports/features/scoreboard/data/models/match_result_model.dart';

abstract class ProfileRemoteDataSource {
  Future<List<MatchResultModel>> getMatchesByUser(String uid);
  Future<UserModel> updateProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    File? imageFile,
  });
}
