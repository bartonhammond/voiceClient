import 'dart:io';

import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/myfamilyvoice-cert.dart' as cert;
import 'package:http/io_client.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
  } else {
    print('good');
    final ArgResults argResults = parser.parse(arguments);

    final GraphQLClient graphQLClient =
        getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

    QueryResult queryResult =
        await getUserByEmail(graphQLClient, 'admin@myfamilyvoice.com');
    print(queryResult.hasException);
  }
  return;
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

GraphQLClient getGraphQLClient(ArgResults argResults, GraphQLClientType type) {
  if (argResults['mode'] == 'prod') {
    const String uri = 'https://myfamilyvoice.com';
    const bool isSecured = true;
    final link = getHttpLink(getHttpLinkUri(uri, type, isSecured));

    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    return graphQLClient;
  }
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

Future<QueryResult> getUserByEmail(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmailForAuthQL),
    variables: <String, dynamic>{
      'email': email,
    },
  );
  return await graphQLClient.query(_queryOptions);
}
