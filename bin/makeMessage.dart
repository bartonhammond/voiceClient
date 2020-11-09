import 'dart:io';

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';

import '../seed/graphQLClient.dart';
import '../seed/queries.dart';
import '../seed/queries.dart' as q;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  parser.addOption('type',
      help: 'what type of message',
      allowed: ['comment', 'friend-request', 'message']);

  parser.addOption('count',
      help: 'create how many messages', allowed: ['one', 'ten']);

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }

  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  //Make everyone friends

  final String _toId =
      await q.getUserIdByEmail(graphQLClient, 'bartonhammond@gmail.com');

  final String _fromId =
      await q.getUserIdByEmail(graphQLClient, 'brucefreeman@gmail.com');

  String storyId;

  if (argResults['mode'] == 'prod') {
    storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }
  if (argResults['mode'] == 'dev') {
    storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }

  final uuid = Uuid();
  int limit = 0;
  if (argResults['count'] == 'one') {
    limit = 1;
  }
  if (argResults['count'] == 'ten') {
    limit = 10;
  }

  if (argResults['type'] == 'comment') {
    for (var i = 0; i < limit; i++) {
      await addUserMessages(
        graphQLClient,
        _fromId,
        _toId,
        uuid.v1(),
        'new',
        'Comment',
        'comment',
        storyId,
      );
    }
  }
  if (argResults['type'] == 'friend-request') {
    for (var i = 0; i < limit; i++) {
      await addUserMessages(
        graphQLClient,
        _fromId,
        _toId,
        uuid.v1(),
        'new',
        'Friend Request',
        'friend-request',
        null,
      );
    }
  }
  const String mp3 =
      'storage/yxF3c4-QB-ebce4820-221e-11eb-85c5-7bff015f4e79.mp3';
  if (argResults['type'] == 'message') {
    for (var i = 0; i < limit; i++) {
      await addUserMessages(
        graphQLClient,
        _fromId,
        _toId,
        uuid.v1(),
        'new',
        'Message',
        'message',
        mp3,
      );
    }
  }
}
