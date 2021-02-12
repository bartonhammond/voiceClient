import 'dart:convert' show json;
import 'dart:io';
import 'dart:io' show File;

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';

import '../seed/graphQLClient.dart';
import '../seed/queries.dart' as q;

Future<void> main(List<String> arguments) async {
  print('main');
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  parser.addOption('tagsFile', help: 'Name of tags file');

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);
  print(Directory.current.absolute);

  final List tags =
      json.decode(await File(argResults['tagsFile']).readAsString());
  print('tags: ${tags.length}');
  final Uuid uuid = Uuid();

  for (var tag in tags) {
    final tagId = uuid.v1();
    print(
        'add tag from: ${tag['u']['properties']['name']} to:${tag['t']['properties']['id']}');

    //create tag
    await q.createTag(
      graphQLClient,
      tagId,
    );

    //create tag story
    await q.addTagStory(
      graphQLClient,
      tag['t']['properties']['story'],
      tagId,
    );

    //create tag user
    await q.addTagUser(
      graphQLClient,
      tag['u']['properties']['id'],
      tagId,
    );
  }
}
