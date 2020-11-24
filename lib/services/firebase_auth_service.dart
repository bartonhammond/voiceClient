import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService implements AuthService {
  final auth.FirebaseAuth _firebaseAuth = auth.FirebaseAuth.instance;

  User _userFromFirebase(auth.User user) {
    if (user == null) {
      return null;
    }

    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  @override
  Future<User> signInWithEmailAndLink({String email, String link}) async {
    final auth.UserCredential userCredentials =
        await _firebaseAuth.signInWithEmailLink(email: email, emailLink: link);

    return _userFromFirebase(userCredentials.user);
  }

  @override
  Future<bool> isSignInWithEmailLink(String link) async {
    return _firebaseAuth.isSignInWithEmailLink(link);
  }

  @override
  Future<void> sendSignInWithEmailLink({
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String iOSBundleID,
    @required String androidPackageName,
    @required bool androidInstallIfNotAvailable,
    @required String androidMinimumVersion,
  }) async {
    final acs = auth.ActionCodeSettings(
        // URL you want to redirect back to. The domain (www.example.com) for this
        // URL must be whitelisted in the Firebase Console.
        url: url,
        // This must be true
        handleCodeInApp: true,
        iOSBundleId: iOSBundleID,
        androidPackageName: androidPackageName,
        androidInstallApp: true,
        androidMinimumVersion: androidMinimumVersion);
    return await _firebaseAuth.sendSignInLinkToEmail(
      email: email,
      actionCodeSettings: acs,
    );
  }

  @override
  Future<User> currentUser() async {
    final auth.User user = _firebaseAuth.currentUser;
    return _userFromFirebase(user);
  }

  @override
  Future<String> currentUserIdToken() async {
    final auth.User user = _firebaseAuth.currentUser;
    final idTokenResult = await user.getIdToken();
    return idTokenResult;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}

  @override
  Future<User> registerWithEmailPassword(String email, String password) async {
    final auth.UserCredential userCredentials =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(userCredentials.user);
  }

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    final auth.UserCredential userCredentials =
        await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return _userFromFirebase(userCredentials.user);
  }
}
