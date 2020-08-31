import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';

GraphQLClient getGraphQLClient(GraphQLClientType type) {
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
