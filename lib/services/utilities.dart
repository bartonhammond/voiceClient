import 'dart:convert';

import 'package:flutter/foundation.dart';

void printJson(Map map) {
  final JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final String prettyprint = encoder.convert(map);
  debugPrint(prettyprint);
}
