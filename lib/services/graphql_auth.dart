import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';

import 'auth_service.dart';

class GraphQLAuth {
  GraphQLAuth(this.context);
  final BuildContext context;
  var port = '4001';
  var endPoint = 'graphql';
  var uri = 'http://192.168.1.39'; //HP
  User user;
  String token;
  String currentUserId;

  void setUser(User user) {
    this.user = user;
  }

  User getUser() {
    return user;
  }

  void setCurrentUserId(String id) {
    print('graphQL_auth.setCurrentUserId: $id');
    currentUserId = id;
  }

  String getCurrentUserId() {
    return currentUserId;
  }

  Future<GraphQLClient> getGraphQLClient(GraphQLClientType type) async {
    if (type == GraphQLClientType.FileServer) {
      port = '4002';
      endPoint = 'query';
    }
    final httpLink = HttpLink(
      uri: '$uri:$port/$endPoint',
    );

    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    final AuthLink authLink = AuthLink(getToken: () async {
      print('graphql_auth getting tokenResult');
      final IdTokenResult tokenResult = await auth.currentUserIdToken();
      print('graphql_auth got tokenResult');
      token = tokenResult.token;
      return 'Bearer $token';
    });

    final link = authLink.concat(httpLink);

    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    return graphQLClient;
  }

  Future<GraphQLClient> setupEnvironment() async {
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getUserByEmail),
      variables: <String, dynamic>{
        'email': user.email,
      },
    );

    final GraphQLClient graphQLClient =
        await getGraphQLClient(GraphQLClientType.ApolloServer);
    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult != null &&
        queryResult.data != null &&
        queryResult.data['User'] != null &&
        queryResult.data['User'].length > 0 &&
        queryResult.data['User'][0]['id'] != null) {
      setCurrentUserId(queryResult.data['User'][0]['id']);
    }
    return graphQLClient;
  }
}
