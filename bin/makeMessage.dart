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

  const String _fromEmail = 'admin@myfamilyvoice.com';
  final String _fromId = await q.getUserIdByEmail(
    graphQLClient,
    _fromEmail,
  );

  const String _toEmail = 'bartonhammond@gmail.com'; //mom
  final String _toId = await q.getUserIdByEmail(
    graphQLClient,
    _toEmail,
  );

  String storyId;

  if (argResults['mode'] == 'prod') {
    storyId = 'e44ab8d0-ed45-11ea-8678-7da3b3f67897';
  }
  if (argResults['mode'] == 'dev') {
    storyId = '9a0426a0-340b-11eb-bdc6-7d2e6529153a';
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
        'comment',
        storyId,
        '',
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
        'friend-request',
        null,
        null,
      );
    }
  }
  const String mp3 =
      'storage/0i-WzcXKJ-d2b32ab0-50fc-11eb-b7aa-e12be0396ee7.mp3';
  if (argResults['type'] == 'message') {
    for (var i = 0; i < limit; i++) {
      await addUserMessages(
        graphQLClient,
        _fromId,
        _toId,
        uuid.v1(),
        'new',
        'message',
        mp3,
        null,
      );
    }
  }
}
