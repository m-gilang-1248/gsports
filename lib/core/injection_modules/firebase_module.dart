import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart' as gs;
import 'package:injectable/injectable.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  @lazySingleton
  FirebaseFirestore get firebaseFirestore => FirebaseFirestore.instance;
  
  @lazySingleton
  gs.GoogleSignIn get googleSignIn {
    // For google_sign_in 7.x on Android, serverClientId (Web Client ID) is required to get idToken.
    // Ensure GOOGLE_SERVER_CLIENT_ID is set in your .env file.
    final serverClientId = dotenv.env['GOOGLE_SERVER_CLIENT_ID'];
    final instance = gs.GoogleSignIn.instance;
    
    if (serverClientId != null && serverClientId.isNotEmpty) {
      instance.initialize(serverClientId: serverClientId);
    }
    
    return instance;
  }
}
