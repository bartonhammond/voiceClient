import 'dart:io';

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/io_client.dart';

import 'package:voiceClient/common_main.dart';
import 'package:voiceClient/constants/myfamilyvoice-cert.dart' as cert;

import 'app_config.dart';
import 'my_app.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';

void main() {
  setup();
  HttpLink getHttpLink(String uri) {
    final SecurityContext securityContext = SecurityContext();
    securityContext.setTrustedCertificatesBytes(cert.myfamilyvoice);

    final HttpClient http = HttpClient(context: securityContext);
    http.badCertificateCallback =
        (X509Certificate cert, String host, int port) {
      print('!!!!Bad certificate');
      return false;
    };

    final IOClient httpClient = IOClient(http);
    return HttpLink(uri: uri, httpClient: httpClient);
  }

  final configuredApp = AppConfig(
    flavorName: 'Prod',
    apiBaseUrl: 'https://myfamilyvoice.com/',
    getHttpLink: getHttpLink,
    isSecured: true,
    child: MyApp(),
  );
/*start app
  runApp(DevicePreview(
    enabled: false,
    builder: (BuildContext context) => MyApp(),
  ));
  */
  runApp(configuredApp);
}
