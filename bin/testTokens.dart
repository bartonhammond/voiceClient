import 'package:MyFamilyVoice/services/utilities.dart';

Future<void> main(List<String> arguments) async {
  Map<String, String> tokenMap = fromStringToTokenMap('');
  if (tokenMap.isNotEmpty) {
    print('1 failed not empty');
  }

  tokenMap = fromStringToTokenMap(null);
  if (tokenMap.isNotEmpty) {
    print('2 failed not empty');
  }

  tokenMap = fromStringToTokenMap('foo:bar');
  if (tokenMap.isEmpty) {
    print('3 failed empty');
  }
  if (tokenMap.length != 1) {
    print('3 failed length ');
  }

  if (!tokenMap.containsKey('foo')) {
    print('3 does not contain foo');
  }

  if (tokenMap['foo'] != 'bar') {
    print('3 foo not equal bar');
  }

  tokenMap = fromStringToTokenMap('foo:bar;more:some');
  if (tokenMap.isEmpty) {
    print('4 failed empty');
  }
  if (tokenMap.length != 2) {
    print('4 failed length ');
  }

  if (!tokenMap.containsKey('foo')) {
    print('4does not contain foo');
  }

  if (tokenMap['foo'] != 'bar') {
    print('4 foo not equal bar');
  }

  if (!tokenMap.containsKey('more')) {
    print('4does not contain more');
  }

  if (tokenMap['more'] != 'some') {
    print('4 more not equal some');
  }

  String tokenString = fromTokenMaptoString(tokenMap);
  if (tokenString != 'foo:bar;more:some') {
    print('5 not foo/more');
  }

  tokenMap = fromStringToTokenMap('foo:bar');
  tokenString = fromTokenMaptoString(tokenMap);
  if (tokenString != 'foo:bar') {
    print('5 not foo:bar');
  }
}
