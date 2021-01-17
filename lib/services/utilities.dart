import 'dart:convert';

import 'package:flutter/foundation.dart';

void printJson(String title, Map map) {
  print(title);
  final JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final String prettyprint = encoder.convert(map);
  debugPrint(prettyprint);
}
