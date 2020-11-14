import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:args/args.dart';
import 'package:graphql/client.dart';

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';

import '../seed/graphQLClient.dart';
import '../seed/queries.dart' as q;
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

Future<void> runQueries(CustomObject customObject) async {
  final GraphQLClient graphQLClient =
      getGraphQLClient(customObject.argResults, GraphQLClientType.ApolloServer);
  final String email = customObject.email;
  print('runQueries $email');
  while (true) {
    await loadStories(graphQLClient, email, getUserStoriesQL, 'userStories');
    await Future<dynamic>.delayed(Duration(seconds: 1));

    await loadStories(
        graphQLClient, email, getUserFriendsStoriesQL, 'userFriendsStories');
    await Future<dynamic>.delayed(Duration(seconds: 1));

    await getSearchFriends(
      graphQLClient,
      email,
      userSearchFriendsQL,
      'userSearchFriends',
    );
    await getSearchFriends(
      graphQLClient,
      email,
      userSearchNotFriendsQL,
      'userSearchNotFriends',
    );
    await getSearchFriends(
      graphQLClient,
      email,
      userSearchMeQL,
      'User',
    );
    await getMessages(graphQLClient, email);
    {}
  }
}

Future<List<dynamic>> getStories(
  GraphQLClient graphQLClient,
  String email,
  String storyQL,
  String resultsName,
) async {
  final String cursor = DateTime.now().toIso8601String();

  return await q.getStoriesQuery(
    graphQLClient,
    email,
    200,
    cursor,
    storyQL,
    resultsName,
  );
}

Future<void> loadStories(
  GraphQLClient graphQLClient,
  String email,
  String storyQL,
  String resultsName,
) async {
  String cursor = DateTime.now().toIso8601String();
  await Future<dynamic>.delayed(Duration(seconds: 1));
  List results = await q.getStoriesQuery(
    graphQLClient,
    email,
    20,
    cursor,
    storyQL,
    resultsName,
  );
  int page = 0;
  while (results.length % 20 == 0 && page < 6) {
    print('$resultsName (page: $page) $email');
    page++;
    cursor = q.getCursor(results);
    await Future<dynamic>.delayed(Duration(seconds: 1));
    results = await q.getStoriesQuery(
        graphQLClient, email, 20, cursor, storyQL, resultsName);
    print('$resultsName size: ${results.length}');
  }
  return;
}

Future<void> getSearchFriends(
  GraphQLClient graphQLClient,
  String email,
  String ql,
  String resultsName,
) async {
  int skip = 0;
  const int limit = 20;
  const String searchString = '*';
  int page = 0;
  List results = await q.userSearchQuery(
    graphQLClient,
    searchString,
    email,
    skip,
    limit,
    ql,
    resultsName,
  );
  print('$resultsName $email page($page) size(${results.length})');
  while (results.length % 20 == 0 && skip < 200) {
    await Future<dynamic>.delayed(Duration(seconds: 1));
    print('$resultsName $email page($page)');
    page++;
    skip += limit;
    results = await q.userSearchQuery(
      graphQLClient,
      searchString,
      email,
      skip,
      limit,
      ql,
      resultsName,
    );
  }
}

Future<void> getMessages(
  GraphQLClient graphQLClient,
  String email,
) async {
  const int count = 20;
  int page = 0;
  String cursor = DateTime.now().toIso8601String();
  List results = await q.getMessagesQuery(
    graphQLClient,
    email,
    count,
    cursor,
  );
  print('getMessages $email page($page) size(${results.length})');
  while (results.length % 20 == 0 && page < 5) {
    await Future<dynamic>.delayed(Duration(seconds: 1));
    print('getMessages $email page($page)');
    page++;
    cursor = q.getCursor(results, fieldName: 'messageCreated');
    results = await q.getMessagesQuery(
      graphQLClient,
      email,
      count,
      cursor,
    );
  }
}
