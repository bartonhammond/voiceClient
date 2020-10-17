import 'package:firebase_auth/firebase_auth.dart';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User _userFromFirebase(FirebaseUser user) {
    if (user == null) {
      return null;
    }

    return User(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
    );
  }

  @override
  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.onAuthStateChanged.map(_userFromFirebase);
  }

  @override
  Future<User> signInWithEmailAndLink({String email, String link}) async {
    final AuthResult authResult =
        await _firebaseAuth.signInWithEmailAndLink(email: email, link: link);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<bool> isSignInWithEmailLink(String link) async {
    return await _firebaseAuth.isSignInWithEmailLink(link);
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
    return await _firebaseAuth.sendSignInWithEmailLink(
      email: email,
      url: url,
      handleCodeInApp: handleCodeInApp,
      iOSBundleID: iOSBundleID,
      androidPackageName: androidPackageName,
      androidInstallIfNotAvailable: androidInstallIfNotAvailable,
      androidMinimumVersion: androidMinimumVersion,
    );
  }

  @override
  Future<User> currentUser() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    return _userFromFirebase(user);
  }

  @override
  Future<IdTokenResult> currentUserIdToken() async {
    final FirebaseUser user = await _firebaseAuth.currentUser();
    final idTokenResult = await user.getIdToken();
    return idTokenResult;
  }

  @override
  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  @override
  void dispose() {}
}
