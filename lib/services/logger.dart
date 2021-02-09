import 'dart:convert';
import 'package:package_info/package_info.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> createMessage({
  String shortMessage,
  String userEmail,
  String source,
  String stackTrace,
}) async {
  String version = 'web';
  String buildNumber = 'web';
  if (!kIsWeb) {
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    buildNumber = packageInfo.buildNumber;
  }
  final data = <String, dynamic>{
    'short_message': shortMessage,
    'host': source,
    'build': '$version+$buildNumber',
    'userEmail': userEmail,
    'stackTrace': stackTrace
  };
  final dynamic body = jsonEncode(data);
  print(body);
  /*
  await http.post(
    'https://myfamilyvoice.com/gelf',
    body: body,
  );*/

  return;
}
