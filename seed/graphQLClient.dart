import 'package:graphql/client.dart';
import 'package:args/args.dart';
import 'package:voiceClient/constants/enums.dart';

GraphQLClient getGraphQLClient(ArgResults argResults, GraphQLClientType type) {
  if (argResults['mode'] == 'prod') {
    const String uri = 'http://192.168.1.44';
    String endPoint = 'apollo/';

    if (type == GraphQLClientType.FileServer) {
      endPoint = 'file/';
    }
    final httpLink = HttpLink(
      uri: '$uri/$endPoint',
    );

    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: httpLink,
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
