import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/common_main.dart';

import 'app_config.dart';
import 'my_app.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';
void main() {
  setup();
  HttpLink getHttpLink(String uri) {
    return HttpLink(uri: uri);
  }

  final configuredApp = AppConfig(
    flavorName: 'Test',
    apiBaseUrl: 'https://myfamilyvoice.com',
    getHttpLink: getHttpLink,
    isSecured: false,
    child: MyApp(
      isTesting: true,
      userEmail: 'charleshammond@gmail.com',
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
