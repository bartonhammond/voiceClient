import 'dart:io';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/mutation_service.dart';
import '../seed/graphQLClient.dart';
import '../seed/voiceUsers.dart';

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

  //Make everyone friends
  for (var userIndex = 0; userIndex < users.length; userIndex++) {
    final String userId =
        await _getUserByEmail(graphQLClient, users[userIndex]['email']);

    final List friends =
        await _getFriendsOfMine(graphQLClient, users[userIndex]['email']);

    for (var friendIndex = 0; friendIndex < friends.length; friendIndex++) {
      if (!friends[friendIndex]['isFriend']) {
        await addUserFriend(
          graphQLClient,
          userId,
          friends[friendIndex]['id'],
        );
        await addUserFriend(
          graphQLClient,
          friends[friendIndex]['id'],
          userId,
        );
      }
    }
  }

  return;
}

Future<String> _getUserByEmail(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getUserByEmail),
    variables: <String, dynamic>{
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  return queryResult.data['User'][0]['id'];
}

Future<List> _getFriendsOfMine(
  GraphQLClient graphQLClient,
  String email,
) async {
  final QueryOptions _queryOptions = QueryOptions(
    documentNode: gql(getFriendsOfMine),
    variables: <String, dynamic>{
      'email': email,
    },
  );
  final QueryResult queryResult = await graphQLClient.query(_queryOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }
  return queryResult.data['friends'];
}
