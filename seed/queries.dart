import 'package:graphql/client.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';

Future<Map<String, dynamic>> getUserByEmail(
  GraphQLClient graphQLClient,
  String email,
  String currentUserEmail,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmailQL),
    variables: <String, dynamic>{
      'email': email,
      'currentUserEmail': currentUserEmail
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['getUserByEmail'];
}

Future<List> getFriendsOfMineByEmail(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getFriendsOfMineQL),
    variables: <String, dynamic>{
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['friends'];
}

Future<String> getUserIdByEmail(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmailQL),
    variables: <String, dynamic>{
      'currentUserEmail': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['getUserByEmail']['id'];
}

String getCursor(List<dynamic> _list, {String fieldName = 'updated'}) {
  String datetime;
  if (_list == null || _list.isEmpty) {
    datetime = DateTime.now().toIso8601String();
  } else {
    datetime = _list[_list.length - 1][fieldName]['formatted'];
  }
  return datetime;
}

Future<List> getStoriesQuery(
  GraphQLClient graphQLClient,
  String email,
  int count,
  String cursor,
  String gqlString,
  String resultsName,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(gqlString),
    variables: <String, dynamic>{
      'email': email,
      'currentUserEmail': email,
      'limit': count.toString(),
      'cursor': cursor
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data[resultsName];
}

Future<List> userSearchQuery(
  GraphQLClient graphQLClient,
  String searchString,
  String email,
  int skip,
  int limit,
  String gqlString,
  String resultsName,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(gqlString),
    variables: <String, dynamic>{
      'searchString': searchString,
      'email': email,
      'limit': limit.toString(),
      'skip': skip.toString()
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data[resultsName];
}

Future<List> getStoryReactions(
  GraphQLClient graphQLClient,
  String storyId,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getStoryReactionsByIdQL),
    variables: <String, dynamic>{
      'id': storyId,
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['storyReactions'];
}

Future<List<dynamic>> getUsers(
  GraphQLClient graphQLClient,
  String searchString,
  String currentUserEmail,
  String limit,
  String skip,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(userSearchQL),
    variables: <String, dynamic>{
      'searchString': searchString,
      'currentUserEmail': currentUserEmail,
      'limit': limit,
      'skip': skip
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['userSearch'];
}

Future<void> addUserBookAuthor(
  GraphQLClient graphQLClient,
  String fromUserId,
  String toUserId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserBookAuthorQL),
    variables: <String, dynamic>{
      'from': fromUserId,
      'to': toUserId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> createReaction(
  GraphQLClient graphQLClient,
  String id,
  String type,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createReactionQL),
    variables: <String, dynamic>{
      'id': id,
      'created': now.toIso8601String(),
      'type': type,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addReactionStory(
  GraphQLClient graphQLClient,
  String storyId,
  String reactionId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addReactionStoryQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'reactionId': reactionId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addReactionFrom(
  GraphQLClient graphQLClient,
  String userId,
  String reactionId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addReactionFromQL),
    variables: <String, dynamic>{
      'userId': userId,
      'reactionId': reactionId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addStoryComments(
  GraphQLClient graphQLClient,
  String storyId,
  String commentId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addStoryCommentsQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'commentId': commentId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addUserComments(
  GraphQLClient graphQLClient,
  String userId,
  String commentId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserCommentsQL),
    variables: <String, dynamic>{
      'userId': userId,
      'commentId': commentId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> createTag(
  GraphQLClient graphQLClient,
  String tagId,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(createTagQL),
    variables: <String, dynamic>{
      'tagId': tagId,
      'created': now.toIso8601String()
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addTagStory(
  GraphQLClient graphQLClient,
  String storyId,
  String tagId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addTagStoryQL),
    variables: <String, dynamic>{
      'storyId': storyId,
      'tagId': tagId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}

Future<void> addTagUser(
  GraphQLClient graphQLClient,
  String userId,
  String tagId,
) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(addTagUserQL),
    variables: <String, dynamic>{
      'userId': userId,
      'tagId': tagId,
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}
