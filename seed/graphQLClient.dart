import 'dart:io';

import 'package:graphql/client.dart';
import 'package:args/args.dart';
import 'package:http/io_client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/myfamilyvoice-cert.dart' as cert;

HttpLink getHttpLink(String uri) {
  final SecurityContext securityContext = SecurityContext();
  securityContext.setTrustedCertificatesBytes(cert.myfamilyvoice);

  final HttpClient http = HttpClient(context: securityContext);
  http.badCertificateCallback = (X509Certificate cert, String host, int port) {
    print('!!!!Bad certificate');
    return false;
  };

  final IOClient httpClient = IOClient(http);
  return HttpLink(uri: uri, httpClient: httpClient);
}

String getHttpLinkUri(
  String apiBaseUrl,
  GraphQLClientType type,
  bool isSecured,
) {
  switch (type) {
    case GraphQLClientType.FileServer:
      return '$apiBaseUrl/file/';
    case GraphQLClientType.Mp3Server:
      return '$apiBaseUrl/mp3';
    case GraphQLClientType.ApolloServer:
      return isSecured
          ? '$apiBaseUrl/apollo/'
          : '$apiBaseUrl/apollo_unsecured/';
    case GraphQLClientType.ImageServer:
      return '$apiBaseUrl/image';
    default:
      throw Exception('invalid parameter: $type');
  }
}

GraphQLClient getGraphQLClient(ArgResults argResults, GraphQLClientType type) {
  print('getGraphQLClient ${argResults["mode"]}');
  if (argResults['mode'] == 'prod') {
    print('running prod');
    const String uri = 'https://myfamilyvoice.com';
    const bool isSecured = false;
    final link = getHttpLink(getHttpLinkUri(uri, type, isSecured));

    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    return graphQLClient;
  }
  print('running dev');
  const String uri = 'http://192.168.1.13';
  String port = '4003'; //this is not secured (export foo=barton)
  const String endPoint = 'graphql';

  if (type == GraphQLClientType.FileServer) {
    port = '4002'; //make sure to start w/ export foo=barton
  }
  final httpLink = HttpLink(
    uri: '$uri:$port/$endPoint',
  );

  final GraphQLClient graphQLClient = GraphQLClient(
    cache: InMemoryCache(),
    link: httpLink,
  );

  return graphQLClient;
}
