import 'dart:io';
import 'dart:math';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/mutation_service.dart';
import '../seed/graphQLClient.dart';
import '../seed/queries.dart';

final List types = <String>['LIKE', 'CLAP', 'KISS', 'HUGS', 'SAD', 'BROKE'];
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
  );
  print('ok');
}

Future<void> build(ArgResults argResults) async {
  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  final users = await getFriendsOfMineByEmail(
    graphQLClient,
    'bartonhammond@gmail.com',
  );

  final Random randonReaction = Random();
  for (var i = 0; i < users.length; i++) {
    users[i]['reaction'] = types[randonReaction.nextInt(6)];
  }
  String _storyId;

  if (argResults['mode'] == 'prod') {
    _storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }
  if (argResults['mode'] == 'dev') {
    _storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }

  final uuid = Uuid();
  int limit = 0;
  if (argResults['count'] == 'one') {
    limit = 1;
  }
  if (argResults['count'] == 'all') {
    limit = users.length;
  }

  for (var i = 0; i < limit; i++) {
    final String _reactionId = uuid.v1();

    //reaction
    await createReaction(
      graphQLClient,
      _reactionId,
      _storyId,
      users[i]['reaction'],
    );

    //from user
    await addReactionFrom(
      graphQLClient,
      users[i]['id'],
      _reactionId,
    );

    //from storyu
    await addStoryReaction(
      graphQLClient,
      _storyId,
      _reactionId,
    );
  }
  return;
}
