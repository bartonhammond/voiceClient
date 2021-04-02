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

Map<String, String> fromStringToTokenMap(String tokenString) {
  final Map<String, String> tokenMap = <String, String>{};
  if (tokenString == null) {
    return tokenMap;
  }
  final List<String> tokens = tokenString.split(';');
  if (tokens[0] != '') {
    for (var token in tokens) {
      final List<String> keyValues = token.split('::');
      if (keyValues.length == 2) {
        tokenMap[keyValues[0]] = keyValues[1];
      }
    }
  }
  return tokenMap;
}

String fromTokenMaptoString(Map<String, String> tokenMap) {
  final Iterable<String> keys = tokenMap.keys;
  String rtn = '';
  for (var key in keys) {
    final String value = tokenMap[key];
    if (rtn == '') {
      rtn = '$key::$value';
    } else {
      rtn = '$rtn;$key::$value';
    }
  }
  return rtn;
}
