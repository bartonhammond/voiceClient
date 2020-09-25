import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import '../seed/graphQLClient.dart';
import '../seed/voiceUsers.dart';

class CustomObject {
  CustomObject(this.argResults, this.email);
  ArgResults argResults;
  String email;
}

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }

  final ArgResults argResults = parser.parse(arguments);

  final isolates = <Isolate>[];
  for (var userIndex = 0; userIndex < users.length; userIndex++) {
    try {
      final CustomObject customObject =
          CustomObject(argResults, users[userIndex]['email']);
      await Future<dynamic>.delayed(Duration(seconds: 2));
      final isolate = await Isolate.spawn(runQuery, customObject);
      isolates.add(isolate);
    } catch (err) {
      print(err);
      rethrow;
    }
  }
  Future.delayed(const Duration(hours: 3), () {
    print('Test is complete');
    for (Isolate i in isolates) {
      if (i != null) {
        i.kill(priority: Isolate.immediate);
        i = null;
        print('Killed');
      }
    }
  });
  return;
}

Future<void> runQuery(CustomObject customObject) async {
  while (true) {
    await runQueries(customObject);
  }
}

Future<void> _getStories(
  GraphQLClient graphQLClient,
  String email,
  String storyQL,
  String resultsName,
) async {
  String cursor = DateTime.now().toIso8601String();
  await Future<dynamic>.delayed(Duration(seconds: 1));
  List results = await _getStoriesQuery(
      graphQLClient, email, 20, cursor, storyQL, resultsName);
  int page = 0;
  while (results.length == 20) {
    print('$resultsName (page: $page) $email');
    page++;
    cursor = getCursor(results, 'updated');
    await Future<dynamic>.delayed(Duration(seconds: 1));
    results = await _getStoriesQuery(
        graphQLClient, email, 20, cursor, storyQL, resultsName);
    print('$resultsName size: ${results.length}');
  }
  return;
}

Future<void> runQueries(CustomObject customObject) async {
  final GraphQLClient graphQLClient =
      getGraphQLClient(customObject.argResults, GraphQLClientType.ApolloServer);
  final String email = customObject.email;
  print('runQueries $email');
  while (true) {
    await _getStories(graphQLClient, email, getUserStories, 'userStories');
    await Future<dynamic>.delayed(Duration(seconds: 1));

    await _getStories(
        graphQLClient, email, getUserFriendsStories, 'userFriendsStories');
    await Future<dynamic>.delayed(Duration(seconds: 1));

    int skip = 0;
    const int limit = 20;
    const String searchString = '*';
    int page = 0;
    List results = await _userSearchNotFriendsQuery(graphQLClient, searchString,
        email, skip, limit, userSearchNotFriends, 'userSearchNotFriends');
    while (results.length == 20) {
      await Future<dynamic>.delayed(Duration(seconds: 1));
      print('userSearchNotFriends $email page($page)');
      page++;
      skip += limit;
      results = await _userSearchNotFriendsQuery(graphQLClient, searchString,
          email, skip, limit, userSearchNotFriends, 'userSearchNotFriends');
    }
  }
}

String getCursor(List<dynamic> _list, String fieldName) {
  String datetime;
  if (_list == null || _list.isEmpty) {
    datetime = DateTime.now().toIso8601String();
  } else {
    datetime = _list[_list.length - 1]['updated']['formatted'];
  }
  return datetime;
}

Future<List> _getStoriesQuery(
  GraphQLClient graphQLClient,
  String email,
  int count,
  String cursor,
  String gqlString,
  String resultsName,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(gqlString),
    variables: <String, dynamic>{
      'email': email,
      'limit': count.toString(),
      'cursor': cursor
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data[resultsName];
}

Future<List> _userSearchNotFriendsQuery(
  GraphQLClient graphQLClient,
  String searchString,
  String email,
  int skip,
  int limit,
  String gqlString,
  String resultsName,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(gqlString),
    variables: <String, dynamic>{
      'searchString': searchString,
      'email': email,
      'limit': limit.toString(),
      'skip': skip.toString()
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data[resultsName];
}
