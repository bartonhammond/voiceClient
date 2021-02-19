import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/ql/user/user_messages_received.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
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

const String deleteBookByNameQL = r'''
mutation deleteBookByName($name: String!) {
  deleteBookByName(name: $name)
}
''';
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

const String deleteUserMessagesByNameQL = r'''
mutation deleteUserMessagesByName($name: String!) {
  deleteUserMessagesByName(name: $name)
}
''';
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
  final UserMessagesReceived userMessagesReceived =
      UserMessagesReceived(useFilter: false);

  final UserQl userQL = UserQl(
    userMessagesReceived: userMessagesReceived,
  );

  final UserSearch userSearch = UserSearch.init(
    graphQLClient,
    userQL,
    currentUserEmail,
  );
  userSearch.setQueryName('getUserByName');
  userSearch.setVariables(<String, dynamic>{
    'currentUserEmail': 'String!',
    'name': 'String!',
  });

  return await userSearch.getItem(<String, dynamic>{
    'currentUserEmail': currentUserEmail,
    'name': name,
  });
}

const String removeUserFriendsFromQL = r'''
  mutation removeUserFriendsFrom($fromFriendInput: ID!, $toUserInput: ID!) {
  RemoveUserFriendsFrom(
    from: { id: $fromFriendInput }
    to: { id: $toUserInput }
  ) {
    __typename
    from {
      id
    }
    to {
      id
    }
  }
}
''';

const String removeUserFriendsToQL = r'''
  mutation removeUserFriendsTo($fromUserInput: ID!, $toFriendInput: ID!) {
  RemoveUserFriendsTo(
    from: { id: $fromUserInput }
    to: { id: $toFriendInput }
  ) {
    __typename
    from {
      id
    }
    to {
      id
    }
  }
}
''';

Future<void> quitFriendship(
  GraphQLClient graphQLClient, {
  String friendId,
  String fromUserId,
  String toUserId,
}) async {
  MutationOptions options = MutationOptions(
    documentNode: gql(removeUserFriendsFromQL),
    variables: <String, dynamic>{
      'fromFriendInput': friendId,
      'toUserInput': toUserId,
    },
  );

  QueryResult queryResult = await graphQLClient.mutate(options);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  options = MutationOptions(
    documentNode: gql(removeUserFriendsToQL),
    variables: <String, dynamic>{
      'fromUserInput': fromUserId,
      'toFriendInput': friendId,
    },
  );

  queryResult = await graphQLClient.mutate(options);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
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

const String deleteMessageQL = r'''
mutation deleteMessage($id: String!) {
  deleteMessage(id: $id)
}
''';
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
