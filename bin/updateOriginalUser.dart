import 'dart:io';

import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/constants/graphql.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';

import 'getUser.dart';
import 'loadTest.dart';

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

  final QueryResult userResult =
      await getUserByEmail(graphQLClient, 'bartonhammond@gmail.com');

  final Map<String, dynamic> user = userResult.data['User'][0];

  final List<dynamic> stories = await getStories(
    graphQLClient,
    'bartonhammond@gmail.com',
    getUserFriendsStoriesQL,
    'userFriendsStories',
  );
  for (var story in stories) {
    if (story['user']['isBook']) {
      print(
          '${story["id"]} ${story["user"]["name"]}  ${story["user"]["isBook"]}');
      await addUserOriginalStories(graphQLClient, user['id'], story['id']);
    }
  }
}

const String addUserOriginalStoriesQL = r'''
mutation addUserOriginalStories($from: _UserInput!, $to: _StoryInput!) {
AddUserOriginalStories(
    from: $from
    to: $to
  ) {
    from {
      email
    }
    to {
      audio
      image
    }
  }
}
''';
Future<void> addUserOriginalStories(
  GraphQLClient graphQLClientApolloServer,
  String currentUserId,
  String storyId,
) async {
  final userInput = {'id': currentUserId};
  final to = {'id': storyId};

  //Remove  Story w/ User
  final MutationOptions _mutationOptions = MutationOptions(
    documentNode: gql(addUserOriginalStoriesQL),
    variables: <String, dynamic>{
      'from': userInput,
      'to': to,
    },
  );

  final QueryResult queryResult =
      await graphQLClientApolloServer.mutate(_mutationOptions);
  if (queryResult.hasException) {
    throw queryResult.exception;
  }

  return;
}
