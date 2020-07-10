import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'auth_service.dart';

import 'package:voiceClient/constants/enums.dart';

class GraphQLAuth {
  const GraphQLAuth(this.context);
  final BuildContext context;

  Future<GraphQLClient> getGraphQLClient(GraphQLClientType type) async {
    var port = '4001';
    if (type == GraphQLClientType.FileServer) {
      port = '4002';
    }
    final httpLink = HttpLink(
      uri: 'http://192.168.1.39:$port/query',
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
