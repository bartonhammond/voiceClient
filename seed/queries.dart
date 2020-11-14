import 'package:graphql/client.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';

Future<String> getUserByEmail(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmailForAuthQL),
    variables: <String, dynamic>{
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  return queryResult.data['User'][0]['id'];
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
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  return queryResult.data['User'][0]['id'];
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

Future<List> getMessagesQuery(
  GraphQLClient graphQLClient,
  String email,
  int count,
  String cursor,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserMessagesQL),
    variables: <String, dynamic>{
      'email': email,
      'status': 'new',
      'limit': count.toString(),
      'cursor': cursor
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['userMessages'];
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

Future<void> addUserMessages(
  GraphQLClient graphQLClient,
  String fromUserId,
  String toUserId,
  String messageId,
  String status,
  String text,
  String type,
  String key1,
) async {
  final DateTime now = DateTime.now();
  final MutationOptions options = MutationOptions(
    documentNode: gql(addUserMessagesQL),
    variables: <String, dynamic>{
      'from': fromUserId,
      'to': toUserId,
      'id': messageId,
      'created': now.toIso8601String(),
      'status': status,
      'text': text,
      'type': type,
      'key1': key1
    },
  );

  final QueryResult result = await graphQLClient.mutate(options);
  if (result.hasException) {
    throw result.exception;
  }

  return;
}
