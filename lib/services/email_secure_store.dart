import 'package:shared_preferences/shared_preferences.dart';

/// Used to store and retrieve the user email address
class EmailSecureStore {
  EmailSecureStore();

  static const String storageUserEmailAddressKey = 'userEmailAddress';

  // email
  Future<void> setEmail(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(storageUserEmailAddressKey, email);
    return;
  }

  Future<void> clearEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageUserEmailAddressKey);
    return;
  }

  Future<String> getEmail() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(storageUserEmailAddressKey);
  }
}
