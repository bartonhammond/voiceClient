import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:graphql/client.dart';

Future<void> deleteBook(
  GraphQLClient graphQLClientApolloServer,
  String email,
) async {
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteBookQL),
    variables: <String, dynamic>{
      'email': email,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

Future<void> deleteBookByName(
  GraphQLClient graphQLClientApolloServer,
  String name,
) async {
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteBookByNameQL),
    variables: <String, dynamic>{
      'name': name,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}

GraphQLClient getGraphQLClient(GraphQLClientType type) {
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
