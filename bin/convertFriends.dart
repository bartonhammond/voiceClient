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

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);

  final GraphQLClient graphQLClient =
      getGraphQLClient(argResults, GraphQLClientType.ApolloServer);
  print(Directory.current.absolute);

  final List friends =
      json.decode(await File('seed/DevFriends.json').readAsString());
  print('friends: ${friends.length}');
  final Uuid uuid = Uuid();
  final List fromTos = <String>[];

  for (var friend in friends) {
    final String fromTo =
        friend['u']['properties']['id'] + friend['o']['properties']['id'];
    if (fromTos.contains(fromTo)) {
      continue;
    }
    fromTos.add(fromTo);

    //create reaction
    final friendId = uuid.v1();
    print('add user friend');
    //create friend
    await q.addUserFriends(
      graphQLClient,
      friendId: friendId,
      fromUserId: friend['u']['properties']['id'],
      toUserId: friend['o']['properties']['id'],
      isFamily: friend['f']['properties']['isFamily'],
    );
  }
}
