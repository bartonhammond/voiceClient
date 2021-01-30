import 'dart:convert' show json;
import 'dart:io';
import 'dart:io' show File;

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';

import '../seed/graphQLClient.dart';
import '../seed/queries.dart' as q;

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

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);
  print(Directory.current.absolute);
  final List reactions =
      json.decode(await File('seed/Neo4jProdRecords.json').readAsString());
  for (var reaction in reactions) {
    //create reaction
    await q.createReaction(
      graphQLClient,
      reaction['r']['properties']['id'],
      reaction['r']['properties']['type'],
    );

    await q.addReactionStory(
      graphQLClient,
      reaction['r']['properties']['story'], //story id
      reaction['r']['properties']['id'], //reaction id
    );

    await q.addReactionFrom(
      graphQLClient,
      reaction['u']['properties']['id'], //userId
      reaction['r']['properties']['id'], //reaction id
    );
  }
}
