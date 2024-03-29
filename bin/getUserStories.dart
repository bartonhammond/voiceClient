import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
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

  const String gqlString = r'''
  query getUserFriendsStories($currentUserEmail: String!, $limit: String!, $cursor: String!) {
    userFriendsStories(currentUserEmail: $currentUserEmail, limit: $limit, cursor: $cursor) {
      __typename
      id
      image
      audio
      type
      user {
        id
        email
        name
        banned {
          from(filter: {User: {email: "bartonhammond@gmail.com"}}) {
            id
            User {
              id
              name
              email
            }
          }
        }
        friends {
          to(filter: { User: { email: "bartonhammond@gmail.com" } }) {
            id
            isFamily
            User {
              id
              email
              name
            }
          }
        }
      }
    }
  }
  ''';
  final List stories = await q.getStoriesQuery(
    graphQLClient,
    'bartonhammond@gmail.com',
    1000,
    '2022-01-01',
    gqlString,
    'userFriendsStories',
  );
  for (var story in stories) {
    printJson('story', story);
  }
}
