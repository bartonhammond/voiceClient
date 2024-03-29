import 'dart:io';

import 'package:MyFamilyVoice/my_app.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/io_client.dart';

import 'package:MyFamilyVoice/common_main.dart';
import 'package:MyFamilyVoice/constants/myfamilyvoice-cert.dart' as cert;

import 'app_config.dart';

String get host => Platform.isAndroid ? '10.0.2.2' : 'localhost';

Future<void> main() async {
  await setup();
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
    apiBaseUrl: 'https://myfamilyvoice.com',
    getHttpLink: getHttpLink,
    isSecured: true,
    isWeb: false,
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
