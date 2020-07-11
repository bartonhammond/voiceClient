import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'package:voiceClient/constants/enums.dart';

import 'auth_service.dart';

class GraphQLAuth {
  GraphQLAuth(this.context);
  final BuildContext context;
  String currentUserId;

  void setCurrentUserId(String id) {
    currentUserId = id;
  }

  String getCurrentUserId() {
    return currentUserId;
  }

  Future<GraphQLClient> getGraphQLClient(GraphQLClientType type) async {
    var port = '4001';
    var endPoint = 'graphql';

    const uri = 'http://192.168.1.39'; //HP

    if (type == GraphQLClientType.FileServer) {
      port = '4002';
      endPoint = 'query';
    }
    final httpLink = HttpLink(
      uri: '$uri:$port/$endPoint',
    );

    final AuthService auth = Provider.of<AuthService>(context, listen: false);

    final IdTokenResult tokenResult = await auth.currentUserIdToken();
    final String token = tokenResult.token;
    final AuthLink authLink = AuthLink(
      getToken: () => 'Bearer $token',
    );

    final link = authLink.concat(httpLink);

    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
    );

    return graphQLClient;
  }
}
