import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<Map> getUserByEmail(
  GraphQLClient graphQLClient,
  String currentUserEmail,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmailQL),
    variables: <String, dynamic>{
      'currentUserEmail': currentUserEmail,
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['getUserByEmail'];
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

Future<QueryResult> getUserMessagesReceived(
  GraphQLClient graphQLClient,
  String userEmail,
  String cursor,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserMessagesReceivedQL),
    variables: <String, dynamic>{
      'currentUserEmail': userEmail,
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
