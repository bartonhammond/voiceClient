import 'dart:io';
import 'dart:math';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import '../seed/graphQLClient.dart';
import '../seed/queries.dart';
import 'loadTest.dart';

final List types = <String>['LIKE', 'WOW', 'JOY', 'HAHA', 'SAD', 'LOVE'];
final List makeReactions = <bool>[false, false, true, false];
final List storyHasReactions = <bool>[true, false, true, true, true];

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
      help: 'creat how many reactions', allowed: ['one', 'all']);

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
    getUserStories,
    'userStories',
  );

  final Random randonReaction = Random();
  final Random makeAReaction = Random();
  final Random storyHasReaction = Random();

  final uuid = Uuid();

  for (var story = 0; story < stories.length; story++) {
    if (!storyHasReactions[storyHasReaction.nextInt(5)]) {
      continue;
    }

    for (var user = 0; user < 15; user++) {
      if (!makeReactions[makeAReaction.nextInt(4)]) {
        continue;
      }
      final String _reactionId = uuid.v1();

      //reaction
      await createReaction(
        graphQLClient,
        _reactionId,
        stories[story]['id'],
        types[randonReaction.nextInt(6)],
      );
      print('created reaction $_reactionId');

      //from user
      await addReactionFrom(
        graphQLClient,
        users[user]['id'],
        _reactionId,
      );
      print('added user ${users[user]["id"]}');

      //from story
      await addStoryReaction(
        graphQLClient,
        stories[story]['id'],
        _reactionId,
      );
      print('added story ${stories[story]["id"]}');
    }
  }
  return;
}
