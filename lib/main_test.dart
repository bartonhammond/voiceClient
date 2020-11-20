import 'dart:io';
import 'package:MyFamilyVoice/my_app.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/common_main.dart';
import 'app_config.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';
void main() {
  setup();
  HttpLink getHttpLink(String uri) {
    return HttpLink(uri: uri);
  }

  final configuredApp = AppConfig(
    flavorName: 'Test',
    apiBaseUrl: 'http://dev-myfamilyvoice.com',
    getHttpLink: getHttpLink,
    isSecured: false,
    child: MyApp(
      isTesting: true,
      userEmail: 'brucefreeman@gmail.com',
    ),
  );

  /*start app
  runApp(DevicePreview(
    enabled: false,
    builder: (BuildContext context) => MyApp(),
  ));
  */
  runApp(configuredApp);
}
