import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<Map> getUserByEmail(
  GraphQLClient graphQLClient,
  String userEmail,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmailQL),
    variables: <String, dynamic>{
      'email': userEmail,
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['User'][0];
}

Future<Map> getUserById(
  GraphQLClient graphQLClient,
  String id,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByIdQL),
    variables: <String, dynamic>{
      'id': id,
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['User'][0];
}

Future<QueryResult> getUserMessages(
  GraphQLClient graphQLClient,
  String userEmail,
  String cursor,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserMessagesQL),
    variables: <String, dynamic>{
      'email': userEmail,
      'status': 'new',
      'limit': '100',
      'cursor': cursor,
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult;
}

Future<Map> getUserFriend(
  GraphQLClient graphQLClient,
  String userEmail,
  String otherEmail,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserFriendQL),
    variables: <String, dynamic>{
      'email': userEmail,
      'otherEmail': otherEmail,
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);

  if (queryResult.hasException) {
    print('getUserFriend hasException ${queryResult.exception}');
    throw queryResult.exception;
  }

  return queryResult.data['userFriend'];
}
