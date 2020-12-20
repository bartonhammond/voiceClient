import 'package:flutter_driver/flutter_driver.dart';

class FlutterDriverUtilsExtension {
  static Future<void> tapQuick(
    FlutterDriver driver,
    SerializableFinder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    await driver.tap(finder, timeout: timeout);
  }
}
