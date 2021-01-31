import 'dart:convert';

void printJson(String title, Map map) {
  print(title);
  final JsonEncoder encoder = JsonEncoder.withIndent('  ');
  final String prettyString = encoder.convert(map);
  prettyString.split('\n').forEach((element) => print(element));
}
