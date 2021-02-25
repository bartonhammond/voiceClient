import 'dart:convert';

void printJson(String title, Map map) {
  print(title);
  final String prettyString = toJson(map);
  prettyString.split('\n').forEach((element) => print(element));
}

String toJson(Map map) {
  final JsonEncoder encoder = JsonEncoder.withIndent('  ');
  return encoder.convert(map);
}
