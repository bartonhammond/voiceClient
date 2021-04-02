// Fix for: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:MyFamilyVoice/constants/globals.dart' as globals;
import 'package:platform_device_id/platform_device_id.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  globals.badgeCount++;
  final bool isSupported = await FlutterAppBadger.isAppBadgeSupported();
  if (isSupported) {
    FlutterAppBadger.updateBadgeCount(globals.badgeCount);
  }
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  ResponsiveSizingConfig.instance.setCustomBreakpoints(ScreenBreakpoints(
    desktop: 950,
    tablet: 600,
    watch: 325,
  ));
  await Firebase.initializeApp();

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true, // Required to display a heads up notification
    badge: true,
    sound: true,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  try {
    globals.deviceId = await PlatformDeviceId.getDeviceId;
  } on PlatformException {
    //ignore - already set
  }
  return;
}
