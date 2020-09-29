import 'dart:io';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import 'package:uuid/uuid.dart';
import 'package:voiceClient/constants/enums.dart';
import 'package:voiceClient/constants/graphql.dart';
import 'package:voiceClient/services/mutation_service.dart';
import '../seed/graphQLClient.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('mode',
      help: 'which enviroment to run with', allowed: ['dev', 'prod']);

  parser.addOption('type',
      help: 'what type of message', allowed: ['comment', 'friend-request']);

  parser.addOption('count',
      help: 'creat how many messages', allowed: ['one', 'ten']);

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
      await _getUserIdByEmail(graphQLClient, 'bartonhammond@gmail.com');

  final String _fromId =
      await _getUserIdByEmail(graphQLClient, 'brucefreeman@gmail.com');

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
}

Future<String> _getUserIdByEmail(
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
