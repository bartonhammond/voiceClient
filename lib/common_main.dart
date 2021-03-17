// Fix for: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('1Handling a background message ${message.messageId}');
  await Firebase.initializeApp();
  print('2Handling a background message ${message.messageId}');
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

  return;
}
