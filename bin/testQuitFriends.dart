import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import '../seed/graphQLClient.dart';
import '../test_driver/graphQL.dart' as graphql;
import '../test_driver/utils/utility.dart' as utility;

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

  final Map<String, dynamic> fromUser = await graphql.getUserByName(
      graphQLClient, 'Yahoo Hammond', 'bartonhammond@gmail.com');

  final Map<String, dynamic> toUser = await graphql.getUserByName(
      graphQLClient, 'Barton Hammond', 'bartonhammond@gmail.com');

  if (fromUser != null && toUser != null) {
    await utility.quitFriendships(
      graphQLClient,
      fromUser,
      toUser,
    );
  }
}
