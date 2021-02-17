import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import '../seed/graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  parser.addOption('friendId1', help: 'friend ID');
  parser.addOption('friendId2', help: 'friend ID');

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);

  await quitFriendship(
    graphQLClient,
    friendId1: argResults['friendId1'],
    friendId2: argResults['friendId2'],
  );
}

Future<void> quitFriendship(
  GraphQLClient graphQLClient, {
  String friendId1,
  String friendId2,
}) async {
  final MutationOptions options = MutationOptions(
    documentNode: gql(deleteFriendsServerSideQL),
    variables: <String, dynamic>{
      'friendId1': friendId1,
      'friendId2': friendId2,
    },
  );

  final QueryResult queryResult = await graphQLClient.mutate(options);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return;
}
