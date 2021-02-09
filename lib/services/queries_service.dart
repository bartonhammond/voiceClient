import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/ql/user/user_search.dart';
import 'package:MyFamilyVoice/ql/user_ql.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

Future<Map> getUserByEmail(
  GraphQLClient graphQLClient,
  String currentUserEmail,
) async {
  final UserQl userQL = UserQl();

  final UserSearch userSearch = UserSearch.init(
    graphQLClient,
    userQL,
    currentUserEmail,
  );
  userSearch.setQueryName('getUserByEmail');
  userSearch.setVariables(<String, dynamic>{
    'currentUserEmail': 'String!',
  });

  return await userSearch.getItem(<String, dynamic>{
    'currentUserEmail': 'bartonhammond@gmail.com',
  });
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
