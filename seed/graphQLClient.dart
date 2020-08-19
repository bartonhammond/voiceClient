import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

GraphQLClient getGraphQLClient(GraphQLClientType type) {
  final String uri = graphQLAuth.getHttpLinkUri(type);

  final httpLink = HttpLink(uri: uri);

  final GraphQLClient graphQLClient = GraphQLClient(
    cache: InMemoryCache(),
    link: httpLink,
  );

  return graphQLClient;
}
