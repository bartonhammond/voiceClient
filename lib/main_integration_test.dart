import 'dart:io';
import 'package:MyFamilyVoice/app_config.dart';
import 'package:MyFamilyVoice/my_app.dart';
import 'package:MyFamilyVoice/services/auth_service_adapter.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/common_main.dart';
import 'package:flutter_driver/driver_extension.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';
Future<void> main() async {
  enableFlutterDriverExtension();
  await setup();
  HttpLink getHttpLink(String uri) {
    return HttpLink(uri: uri);
  }

  final configuredApp = AppConfig(
    flavorName: 'Test',
    apiBaseUrl: 'http://192.168.1.13',
    getHttpLink: getHttpLink,
    isSecured: false,
    isWeb: false,
    authServiceType: AuthServiceType.mock,
    child: MyApp(
      initialAuthServiceType: AuthServiceType.mock,
    ),
  );
  runApp(configuredApp);
}
