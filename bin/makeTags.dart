import 'dart:io';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:MyFamilyVoice/constants/enums.dart';

import '../seed/graphQLClient.dart';
import '../seed/queries.dart';
import 'loadTest.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption(
    'mode',
    help: 'which enviroment to run with',
    allowed: ['dev', 'prod'],
  );

  parser.addOption(
    'action',
    help: 'build or process the reactions',
    allowed: ['build', 'process'],
  );

  parser.addOption('count',
      help: 'create how many tags', allowed: ['one', 'five']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }

  final ArgResults argResults = parser.parse(arguments);

  if (argResults['action'] == 'build') {
    await build(argResults);
  } else if (argResults['action'] == 'process') {
    await process(argResults);
  }
}

Future<void> process(ArgResults argResults) async {
  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  String _storyId;

  if (argResults['mode'] == 'prod') {
    _storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }
  if (argResults['mode'] == 'dev') {
    _storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }
  //reaction
  final reactions = await getStoryReactions(
    graphQLClient,
    _storyId,
    'bartonhammond@gmail.com',
  );

  print('ok ${reactions.length}');
}

Future<void> build(ArgResults argResults) async {
  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  final users = await getFriendsOfMineByEmail(
    graphQLClient,
    'bartonhammond@gmail.com',
  );

  final stories = await getStories(
    graphQLClient,
    'bartonhammond@gmail.com',
    getUserStoriesQL,
    'userStories',
  );

  // for 3 people, create tags on the first story
  final Map<String, dynamic> _story = stories[0];
  print('MakeTags storyId: ${_story["id"]}');
  int limit;
  if (argResults['count'] == 'one') {
    limit = 1;
  }
  if (argResults['count'] == 'five') {
    limit = 5;
  }
  for (var user = 0; user < limit; user++) {
    print('adding tag for ${users[user]["email"]}');
    /*
    mutation_service has some UI stuff....
    addStoryTag(
      'bartonhammond@gmail.com',
      graphQLClient,
      _story,
      users[user],
    );
    */
  }
}
