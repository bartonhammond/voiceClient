import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:MyFamilyVoice/ql/story/story_comments.dart';
import 'package:MyFamilyVoice/ql/story/story_original_user.dart';
import 'package:MyFamilyVoice/ql/story/story_reactions.dart';
import 'package:MyFamilyVoice/ql/story/story_search.dart';
import 'package:MyFamilyVoice/ql/story/story_tags.dart';
import 'package:MyFamilyVoice/ql/story/story_user.dart';
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
  final StoryReactions storyReactions = StoryReactions();
  final StoryUser storyUser = StoryUser();
  final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
  final StoryComments storyComments = StoryComments();
  final StoryTags storyTags = StoryTags();
  final StoryQl storyQl = StoryQl(
    storyTags: storyTags,
    storyOriginalUser: storyOriginalUser,
    storyUser: storyUser,
    storyComments: storyComments,
    storyReactions: storyReactions,
  );
  final StorySearch storySearch = StorySearch.init(
    graphQLClient,
    storyQl,
    'bartonhammond@yahoo.com',
  );
  storySearch.setQueryName('getStoryById');
  storySearch.setVariables(
    <String, dynamic>{
      'id': 'String!',
      'currentUserEmail': 'String!',
    },
  );

  final Map story = await storySearch.getItem(<String, dynamic>{
    'id': '9981d610-5fe3-11eb-a316-7ddfac28bd86',
    'currentUserEmail': 'bartonhammond@yahoo.com',
  });

  printJson('${story["id"]}', story);
}
