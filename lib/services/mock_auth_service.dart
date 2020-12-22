import 'dart:async';
import 'package:MyFamilyVoice/services/auth_service.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:random_string/random_string.dart' as random;

/// Mock authentication service to be used for testing the UI
/// Keeps an in-memory store of registered accounts so that registration and sign in flows can be tested.
class MockAuthService implements AuthService {
  MockAuthService({
    this.startupTime = const Duration(milliseconds: 250),
    this.responseTime = const Duration(seconds: 2),
  }) {
    Future<void>.delayed(responseTime).then((_) {
      _add(null);
    });
  }
  final Duration startupTime;
  final Duration responseTime;

  final Map<String, _UserData> _usersStore = <String, _UserData>{};

  User _currentUser;

  final StreamController<User> _onAuthStateChangedController =
      StreamController<User>();
  @override
  Stream<User> get onAuthStateChanged => _onAuthStateChangedController.stream;

  @override
  Future<User> signInWithEmailAndLink({String email, String link}) async {
    await Future<void>.delayed(responseTime);
    final User user = User(
      uid: random.randomAlphaNumeric(32),
      email: email,
    );

    _add(user);
    return user;
  }

  @override
  Future<bool> isSignInWithEmailLink(String link) async {
    return true;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future<void>.delayed(startupTime);
    return;
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
  }) async {}

  @override
  Future<User> currentUser() async {
    await Future<void>.delayed(startupTime);
    return _currentUser;
  }

  @override
  Future<String> currentUserIdToken() async {
    return 'currentUserIdToken';
  }

  @override
  Future<void> signOut() async {
    _add(null);
  }

  void _add(User user) {
    _currentUser = user;
    _onAuthStateChangedController.add(user);
  }

  @override
  void dispose() {
    _onAuthStateChangedController.close();
  }

  @override
  Future<User> registerWithEmailPassword(String email, String password) async {
    await Future<void>.delayed(responseTime);
    final User user = User(
      uid: random.randomAlphaNumeric(32),
      email: email,
    );

    _add(user);
    return user;
  }

  @override
  Future<User> signInWithEmailPassword(String email, String password) async {
    await Future<void>.delayed(responseTime);
    if (!_usersStore.keys.contains(email)) {
      throw PlatformException(
        code: 'ERROR_USER_NOT_FOUND',
        message: 'The email address is not registered. Need an account?',
      );
    }
    final _UserData _userData = _usersStore[email];
    if (_userData.password != password) {
      throw PlatformException(
        code: 'ERROR_WRONG_PASSWORD',
        message: 'The password is incorrect. Please try again.',
      );
    }
    _add(_userData.user);
    return _userData.user;
  }
}

class _UserData {
  _UserData({@required this.password, @required this.user});
  final String password;
  final User user;
}
