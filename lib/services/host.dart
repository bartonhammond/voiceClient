import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';
import 'graphql_auth.dart';

final key = hex.decode(
    '900958d415d1e0de45216e599761d292ba5c79612cb4688313a257a62661bd8904d13e09b9348d365c07976d631ed8b5d269ff7607f59f9ab7186ce493670dec');
final salt = hex.decode(
    'ca483c3ce7659a1e9d27d6e4bf3ddfcf73b83c7faafbe772b56b4af3f5ded60c4453a02549ce220f489edd99dabe9f26a59d5d48e072d69b5f30c78e1562f108');

final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

String host(
  String path, {
  String resizingType = 'fit',
  int width = 100,
  int height = 100,
  String gravity = 'sm',
  int enlarge = 0,
}) {
  if (path.contains('http')) {
    return path;
  }
  if (path.endsWith('mp3')) {
    final String url =
        '${graphQLAuth.getHttpLinkUri(GraphQLClientType.Mp3Server, false)}$path';
    return url;
  }
  if (path.startsWith('storage/')) {
    path = path.substring('storage/'.length);
  }
  final String url = 'local:///$path';

  const extension = 'jpg';

  final urlEncoded = urlSafeBase64(utf8.encode(url));

  final pathPart =
      '/$resizingType/$width/$height/$gravity/$enlarge/$urlEncoded.$extension';

  final signature = sign(salt, utf8.encode(pathPart), key);

  final _location =
      '${graphQLAuth.getHttpLinkUri(GraphQLClientType.ImageServer, false)}/$signature$pathPart';
  return _location;
}

String urlSafeBase64(dynamic buffer) {
  return base64
      .encode(buffer)
      .replaceAll('=', '')
      .replaceAll('+', '-')
      .replaceAll('/', '_');
}

String sign(dynamic salt, dynamic path, dynamic key) {
  final hmac = Hmac(sha256, key);
  final digest = hmac.convert(salt + path);
  return urlSafeBase64(digest.bytes);
}
