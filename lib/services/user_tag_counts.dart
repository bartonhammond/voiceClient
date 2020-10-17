import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:MyFamilyVoice/services/graphql_auth.dart';
import 'package:MyFamilyVoice/services/service_locator.dart';

Future<List<String>> getUserHashtagCounts() async {
  try {
    final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();

    final GraphQLClient graphQLClient =
        graphQLAuth.getGraphQLClient(GraphQLClientType.ApolloServer);

    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(userHashTagsCountQL),
      variables: <String, dynamic>{
        'email': graphQLAuth.getUserMap()['email'],
      },
    );
    List<String> tags = [];
    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult.hasException) {
      throw queryResult.exception;
    }
    if (!queryResult.hasException) {
      List<dynamic> tagCounts = <dynamic>[];
      if (queryResult.data != null)
        tagCounts = queryResult.data['userHashTagsCount'];

      for (var i = 0; i < tagCounts.length; i++) {
        tags.add(tagCounts[i]['hashtag']);
      }
    }
    tags = tags.toSet().toList();
    return tags;
  } catch (e) {
    rethrow;
  }
}
