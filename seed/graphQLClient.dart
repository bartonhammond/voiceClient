import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';

GraphQLClient getGraphQLClient(GraphQLClientType type) {
  var port = '4003'; //this one is not secured
  var endPoint = 'graphql';

  const uri = 'http://192.168.1.44'; //HP

  if (type == GraphQLClientType.FileServer) {
    port = '4002';
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
