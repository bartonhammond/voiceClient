import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info/package_info.dart';

Future<void> createMessage({
  String shortMessage,
  String userEmail,
  String source,
  String stackTrace,
}) async {
  final PackageInfo packageInfo = await PackageInfo.fromPlatform();
  final String version = packageInfo.version;
  final String buildNumber = packageInfo.buildNumber;

  final data = <String, dynamic>{
    'short_message': shortMessage,
    'host': source,
    'build': '$version+$buildNumber',
    'userEmail': userEmail,
    'stackTrace': stackTrace
  };
  final dynamic body = jsonEncode(data);

  await http.post(
    'http://192.168.1.48:12201/gelf',
    body: body,
  );

  return;
}
