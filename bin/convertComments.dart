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
  parser.addOption('commentsFile', help: 'Name of comments file');
  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);
  print(Directory.current.absolute);

  final List comments = json.decode(await File(
    argResults['commentsFile'],
  ).readAsString());
  print('comments: ${comments.length}');
  final Uuid uuid = Uuid();

  for (var comment in comments) {
    final commentId = uuid.v1();
    print(
        'add comment from: ${comment['u']['properties']['name']} to:${comment['c']['properties']['id']}');

    //create comment
    await q.createComment(
      graphQLClient,
      commentId,
      comment['c']['properties']['story'],
      comment['c']['properties']['audio'],
      comment['c']['properties']['status'],
    );

    //add user comments
    await q.addStoryComments(
      graphQLClient,
      comment['c']['properties']['story'],
      commentId,
    );

    //add story comments
    await q.addUserComments(
      graphQLClient,
      comment['u']['properties']['id'],
      commentId,
    );
  }
}
