/*
   * Not sure why GraphQLProvider wouldn't work here....
   */
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:voiceClient/services/graphql_auth.dart';
import 'package:voiceClient/services/service_locator.dart';

GraphQLClient getGraphQLClient(
  BuildContext context,
  GraphQLClientType type,
) {
  final GraphQLAuth graphQLAuth = locator<GraphQLAuth>();
  final uri = graphQLAuth.getHttpLinkUri(type);
  final httpLink = HttpLink(uri: uri);

  final AuthService auth = Provider.of<AuthService>(context, listen: false);

  final AuthLink authLink = AuthLink(getToken: () async {
    final IdTokenResult tokenResult = await auth.currentUserIdToken();
    return 'Bearer ${tokenResult.token}';
  });

  final link = authLink.concat(httpLink);

  final GraphQLClient graphQLClient = GraphQLClient(
    cache: InMemoryCache(),
    link: link,
  );

  return graphQLClient;
}
