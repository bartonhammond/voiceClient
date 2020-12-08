import 'dart:ui';
import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Used to store and retrieve the user locale between
/// activiation link and homepage
class LocaleSecureStore {
  static const String storageUserLocaleAddressKey = 'userLocale';

  // email
  Future<void> setLocale(String languageCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(storageUserLocaleAddressKey, languageCode);
    return;
  }

  Future<void> clearLocale() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageUserLocaleAddressKey);
  }

  Future<Locale> getLocale() async {
    String languageCode;
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    languageCode = prefs.getString(storageUserLocaleAddressKey);

    if (languageCode == null) {
      final Locale locale = await DeviceLocale.getCurrentLocale();
      languageCode = locale.languageCode;
      await setLocale(locale.languageCode);
    }
    return Locale(languageCode);
  }
}
