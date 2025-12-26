import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';
import 'package:gsports/core/error/exceptions.dart';
import 'package:gsports/features/auth/data/models/user_model.dart';
import 'package:gsports/features/scoreboard/data/models/match_result_model.dart';
import 'package:gsports/core/services/cloudinary_service.dart';
import 'profile_remote_data_source.dart';

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final CloudinaryService cloudinaryService;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    required this.cloudinaryService,
  });

  @override
  Future<List<MatchResultModel>> getMatchesByUser(String uid) async {
    try {
      final snapshot = await firestore
          .collection('matches')
          .where('players', arrayContains: uid)
          .get();

      return snapshot.docs
          .map((doc) => MatchResultModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    String? displayName,
    String? phoneNumber,
    File? imageFile,
  }) async {
    try {
      String? imageUrl;

      // 1. Upload image if present (Using Cloudinary)
      if (imageFile != null) {
        imageUrl = await cloudinaryService.uploadImage(
          imageFile,
          folder: 'profile_pics',
        );
      }

      // 2. Prepare update data for Firestore
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (phoneNumber != null) updates['phoneNumber'] = phoneNumber;
      if (imageUrl != null) updates['photoUrl'] = imageUrl;

      if (updates.isNotEmpty) {
        await firestore.collection('users').doc(uid).update(updates);
      }

      // 3. Sync with FirebaseAuth
      final user = firebaseAuth.currentUser;
      if (user != null) {
        if (displayName != null) await user.updateDisplayName(displayName);
        if (imageUrl != null) await user.updatePhotoURL(imageUrl);
      }

      // 4. Return updated user model
      final doc = await firestore.collection('users').doc(uid).get();
      return UserModel.fromFirebaseUser(user!, doc);
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
