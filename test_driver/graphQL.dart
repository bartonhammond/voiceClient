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

Future<void> deleteUserMessagesByName(
  GraphQLClient graphQLClientApolloServer,
  String name,
) async {
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteUserMessagesByNameQL),
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

Future<Map> getUserByName(
  GraphQLClient graphQLClient,
  String name,
  String currentUserEmail,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByNameQL),
    variables: <String, dynamic>{
      'name': name,
      'currentUserEmail': currentUserEmail,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['getUserByName'];
}

Future<void> quitFriendship(
  GraphQLClient graphQLClient,
  String idFrom,
  String idTo,
) async {
  MutationOptions options = MutationOptions(
    documentNode: gql(removeUserFriends),
    variables: <String, dynamic>{
      'from': idFrom,
      'to': idTo,
    },
  );

  await graphQLClient.mutate(options);

  options = MutationOptions(
    documentNode: gql(removeUserFriends),
    variables: <String, dynamic>{
      'from': idTo,
      'to': idFrom,
    },
  );

  await graphQLClient.mutate(options);
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

Future<void> deleteBanned(
  GraphQLClient graphQLClientApolloServer,
  String email,
) async {
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteBannedQL),
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

Future<List<dynamic>> getUserStories(
  GraphQLClient graphQLClient,
  String currentUserEmail,
  String limit,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserFriendsStoriesQL),
    variables: <String, dynamic>{
      'currentUserEmail': currentUserEmail,
      'limit': limit,
      'cursor': DateTime.now().toIso8601String(),
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['userFriendsStories'];
}

Future<void> deleteUserReactionToStory(
  GraphQLClient graphQLClient,
  String email,
  String storyId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(deleteUserReactionToStoryQL),
    variables: <String, dynamic>{
      'email': email,
      'storyId': storyId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> deleteMessage(
  GraphQLClient graphQLClientApolloServer,
  String messageId,
) async {
  //delete the message
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(deleteMessageQL),
    variables: <String, dynamic>{
      'id': messageId,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);

  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}
