import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gs;
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
    String role = 'user',
  });

  Future<UserModel> signInWithGoogle({String? role});

  Future<void> logout();

  Future<UserModel> getCurrentUser();
}

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final gs.GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.googleSignIn,
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
    String role = 'user',
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
        role: role,
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
  Future<UserModel> signInWithGoogle({String? role}) async {
    try {
      // In google_sign_in 7.2.0, authenticate() is the interactive entry point.
      final gs.GoogleSignInAccount googleUser = await googleSignIn.authenticate();
      
      final gs.GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        // accessToken is missing from GoogleSignInAuthentication in 7.2.0
      );

      final UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        throw ServerException('User is null after Google Sign-In.');
      }

      final userDocRef = firebaseFirestore
          .collection(FirebaseConstants.usersCollection)
          .doc(user.uid);
      final userDoc = await userDocRef.get();

      if (!userDoc.exists) {
        final userData = UserModel.toFirestoreCreateData(
          uid: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          photoUrl: user.photoURL,
          role: role ?? 'user', // Use passed role or default to 'user'
        );
        await userDocRef.set(userData, SetOptions(merge: true));
      }

      final finalDoc = await userDocRef.get();
      return UserModel.fromFirebaseUser(user, finalDoc);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('FirebaseAuthException during Google Sign-In: $e');
      throw ServerException(e.message ?? 'Firebase Auth Error', stackTrace: st);
    } on FirebaseException catch (e, st) {
      debugPrint('FirebaseException during Google Sign-In: $e');
      throw ServerException(e.message ?? 'Firebase Error', stackTrace: st);
    } catch (e, st) {
      debugPrint('Unknown error during Google Sign-In: $e');
      if (e is AuthException) rethrow;
      throw ServerException(e.toString(), stackTrace: st);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await googleSignIn.signOut();
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
