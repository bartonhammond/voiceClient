import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story_ql.dart';
import 'package:MyFamilyVoice/services/utilities.dart';
import 'package:args/args.dart';
import 'package:graphql/client.dart';
import '../seed/graphQLClient.dart';

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

  final StoryQl storyQl = StoryQl();

  final StorySearch storySearch = StorySearch.init(
    graphQLClient,
    storyQl,
    'bartonhammond@gmail.com',
  );
  storySearch.setQueryName('getStoryById');
  storySearch.setVariables(
    <String, dynamic>{
      'id': 'String!',
      'currentUserEmail': 'String!',
    },
  );

  final Map story = await storySearch.getItem(<String, dynamic>{
    'id': 'ba0b98c0-5fdf-11eb-9efe-afe2c5951ee4',
    'currentUserEmail': 'bartonhammond@gmail.com',
  });

  printJson('${story["id"]}', story);
}
