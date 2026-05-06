import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

ValueNotifier<AuthService> authService = ValueNotifier(AuthService());

class AuthService {
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  User? get currentUser => FirebaseAuth.instance.currentUser;

  Stream<User?> get authStateChanges =>
      FirebaseAuth.instance.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) async {
    return await firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<User?> signInWithGoogle() async {
    // Sign out first so the account picker always appears (avoids silent
    // re-use of a cached account that may belong to a different Firebase
    // project or have a stale token).
    await _googleSignIn.signOut();

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // user cancelled

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Both tokens are required. If either is null the credential will be
    // rejected by Firebase — surface a clear error instead of a silent null.
    if (googleAuth.idToken == null) {
      throw Exception(
        'Google Sign-In failed: idToken is null.\n'
        'Make sure a SHA-1 fingerprint is registered in the Firebase console '
        'for package "com.example.plant_care" and that the google-services.json '
        'has been re-downloaded after adding it.',
      );
    }

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await firebaseAuth
        .signInWithCredential(credential);
    return userCredential.user;
  }

  Future<void> signOut() async {
    await Future.wait([firebaseAuth.signOut(), _googleSignIn.signOut()]);
  }
}
