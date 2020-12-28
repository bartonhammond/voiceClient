import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<QueryResult> getUserByEmail(
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
  return queryResult;
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
      'limit': '1',
      'cursor': cursor,
    },
  );

  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult;
}
