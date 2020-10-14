import 'dart:ui';
import 'package:flutter_device_locale/flutter_device_locale.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:meta/meta.dart';

/// Used to store and retrieve the user locale between
/// activiation link and homepage
class LocaleSecureStore {
  LocaleSecureStore({@required this.flutterSecureStorage})
      : assert(flutterSecureStorage != null);
  final FlutterSecureStorage flutterSecureStorage;

  static const String storageUserLocaleAddressKey = 'userLocale';

  // email
  Future<void> setLocale(String languageCode) async {
    await flutterSecureStorage.write(
        key: storageUserLocaleAddressKey, value: languageCode);
  }

  Future<void> clearLocale() async {
    await flutterSecureStorage.delete(key: storageUserLocaleAddressKey);
  }

  Future<Locale> getLocale() async {
    String languageCode =
        await flutterSecureStorage.read(key: storageUserLocaleAddressKey);

    if (languageCode == null) {
      final Locale locale = await DeviceLocale.getCurrentLocale();
      languageCode = locale.languageCode;
      await setLocale(locale.languageCode);
    }
    return Locale(languageCode);
  }
}
