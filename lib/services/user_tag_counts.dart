import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/graphql_client.dart';
import 'package:voiceClient/services/service_locator.dart';

Future<List<String>> getUserHashtagCounts(BuildContext context) async {
  try {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
    final GraphQLClient graphQLClient = getGraphQLClient(
      context,
      GraphQLClientType.ApolloServer,
    );

    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(userHashTagsCountQL),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );

    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    final List<dynamic> tagCounts = queryResult.data['userHashTagsCount'];
    List<String> tags = [];
    for (var i = 0; i < tagCounts.length; i++) {
      tags.add(tagCounts[i]['hashtag']);
    }
    tags = tags.toSet().toList();
    return tags;
  } catch (e) {
    print(e.toString());
    rethrow;
  }
}
