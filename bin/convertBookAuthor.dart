import 'dart:io';

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

  final List<dynamic> users = await q.getUsers(
      graphQLClient, '*', 'bartonhammond@gmail.com', '1000', '0');
  for (var user in users) {
    if (user['isBook']) {
      final Map bookAuthor = await q.getUserByEmail(
        graphQLClient,
        user['bookAuthorEmail'],
        'bartonhammond@gmail.com',
      );

      print('user: $user');
      print('fromId: ${bookAuthor["email"]}');

      await q.addUserBookAuthor(graphQLClient, user['id'], bookAuthor['id']);
    }
  }
}
