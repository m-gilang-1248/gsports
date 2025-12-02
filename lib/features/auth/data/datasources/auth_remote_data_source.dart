import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

import 'package:flutter/foundation.dart';

import 'package:gsports/core/constants/firebase_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  });

  Future<UserModel> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  @override
  Future<UserModel> loginWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user == null) {
        throw ServerException('User is null after login.');
      }
      final userDoc = await firebaseFirestore
          .collection(FirebaseConstants.usersCollection)
          .doc(userCredential.user!.uid)
          .get();

      if (!userDoc.exists) {
        // This case should ideally not happen if registration always creates a doc.
        // But adding a fallback just in case or for existing users before this feature.
        throw ServerException('User document not found in Firestore.');
      }

      return UserModel.fromFirebaseUser(userCredential.user!, userDoc);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('FirebaseAuthException during login: $e');
      throw ServerException(e.message ?? 'Firebase Auth Error', stackTrace: st);
    } on FirebaseException catch (e, st) {
      debugPrint('FirebaseException during login: $e');
      throw ServerException(e.message ?? 'Firebase Error', stackTrace: st);
    } catch (e, st) {
      debugPrint('Unknown error during login: $e');
      throw ServerException(e.toString(), stackTrace: st);
    }
  }

  @override
  Future<UserModel> registerWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user == null) {
        throw ServerException('User is null after registration.');
      }

      await user.updateDisplayName(displayName);

      // Create user document in Firestore
      final userData = UserModel.toFirestoreCreateData(
        uid: user.uid,
        email: email,
        displayName: displayName,
        photoUrl: user.photoURL,
      );
      await firebaseFirestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .set(userData);

      final userDoc = await firebaseFirestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      return UserModel.fromFirebaseUser(user, userDoc);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('FirebaseAuthException during registration: $e');
      throw ServerException(e.message ?? 'Firebase Auth Error', stackTrace: st);
    } on FirebaseException catch (e, st) {
      debugPrint('FirebaseException during registration: $e');
      throw ServerException(e.message ?? 'Firebase Error', stackTrace: st);
    } catch (e, st) {
      debugPrint('Unknown error during registration: $e');
      throw ServerException(e.toString(), stackTrace: st);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await firebaseAuth.signOut();
    } on FirebaseException catch (e, st) {
      debugPrint('FirebaseException during logout: $e');
      throw ServerException(e.message ?? 'Firebase Error', stackTrace: st);
    } catch (e, st) {
      debugPrint('Unknown error during logout: $e');
      throw ServerException(e.toString(), stackTrace: st);
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthException('No authenticated user found.');
      }

      final userDoc = await firebaseFirestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        throw ServerException(
          'User document not found in Firestore for current user.',
        );
      }

      return UserModel.fromFirebaseUser(user, userDoc);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('FirebaseAuthException getting current user: $e');
      throw ServerException(e.message ?? 'Firebase Auth Error', stackTrace: st);
    } on FirebaseException catch (e, st) {
      debugPrint('FirebaseException getting current user: $e');
      throw ServerException(e.message ?? 'Firebase Error', stackTrace: st);
    } catch (e, st) {
      debugPrint('Unknown error getting current user: $e');
      throw ServerException(e.toString(), stackTrace: st);
    }
  }
}
