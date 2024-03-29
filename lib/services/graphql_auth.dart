import 'package:MyFamilyVoice/services/updateUserToken.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import '../app_config.dart';
import 'auth_service.dart';

class GraphQLAuth {
  GraphQLAuth(this.context);
  final BuildContext context;
  User user;
  User originalUser;
  String token;
  Map<String, dynamic> _userMap;
  Map<String, dynamic> _originalUserMap;

  void clear() {
    user = null;
    originalUser = null;
    token = null;
    _userMap = null;
    _originalUserMap = null;
  }

  String getHttpLinkUri(
    GraphQLClientType type,
    bool isSecured,
  ) {
    final config = AppConfig.of(context);
    final String apiBaseUrl = config.apiBaseUrl;
    switch (type) {
      case GraphQLClientType.FileServer:
        return '$apiBaseUrl/file/';
      case GraphQLClientType.Mp3Server:
        return '$apiBaseUrl/mp3';
      case GraphQLClientType.ApolloServer:
        return isSecured
            ? '$apiBaseUrl/apollo/'
            : '$apiBaseUrl/apollo_unsecured/';
      case GraphQLClientType.ImageServer:
        return '$apiBaseUrl/image';
      default:
        throw Exception('invalid parameter: $type');
    }
  }

  Map<String, dynamic> getUserMap() {
    return _userMap;
  }

  Map<String, dynamic> getOriginalUserMap() {
    return _originalUserMap;
  }

//Only called after someone logs in either
//web or device
  void setUser(User _user) {
    originalUser = _user;
    user = _user;
    _userMap = null;
    //this gets set in setupEnvironment
    _originalUserMap = null;
  }

  User getUser() {
    return user;
  }

  GraphQLClient getGraphQLClient(GraphQLClientType type) {
    final config = AppConfig.of(context);
    final HttpLink httpLink = config.getHttpLink(getHttpLinkUri(
      type,
      config.isSecured,
    ));
    Link link;

    if (config.isSecured) {
      final AuthService auth = Provider.of<AuthService>(context, listen: false);
      final AuthLink authLink = AuthLink(getToken: () async {
        final dynamic tokenResult = await auth.currentUserIdToken();
        token = tokenResult;

        ///   web ? .token;
        return 'Bearer $token';
      });
      link = authLink.concat(httpLink);
    } else {
      link = httpLink;
    }

    //Trying to get rid of cacheing
    //https://github.com/zino-app/graphql-flutter/issues/692
    final policies = Policies(
      fetch: FetchPolicy.noCache,
    );
    final GraphQLClient graphQLClient = GraphQLClient(
      cache: InMemoryCache(),
      link: link,
      defaultPolicies: DefaultPolicies(
        watchQuery: policies,
        query: policies,
        mutate: policies,
      ),
    );

    return graphQLClient;
  }

  Future<GraphQLClient> setupEnvironment() async {
    if (user == null) {
      return null;
    }
    final QueryOptions _queryOptions = QueryOptions(
      documentNode: gql(getUserByEmailForAuthQL),
      variables: <String, dynamic>{
        'email': user.email,
      },
    );

    final GraphQLClient graphQLClient =
        getGraphQLClient(GraphQLClientType.ApolloServer);
    final QueryResult queryResult = await graphQLClient.query(_queryOptions);
    if (queryResult != null &&
        queryResult.data != null &&
        queryResult.data['User'] != null &&
        queryResult.data['User'].length > 0 &&
        queryResult.data['User'][0]['id'] != null) {
      _userMap = queryResult.data['User'][0];
      _originalUserMap ??= <String, dynamic>{..._userMap};

      final String _token = await FirebaseMessaging.instance.getToken();

      await updateFirebaseUserToken(graphQLClient, _userMap, _token);

      FirebaseMessaging.instance.onTokenRefresh.listen((String _token) async {
        await updateFirebaseUserToken(graphQLClient, _userMap, _token);
      });
    }
    return graphQLClient;
  }
}
