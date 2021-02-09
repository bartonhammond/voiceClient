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
  final StoryUser storyUser = StoryUser();
  final StoryOriginalUser storyOriginalUser = StoryOriginalUser();
  final StoryComments storyComments = StoryComments();
  final StoryReactions storyReactions = StoryReactions(useFilter: true);
  final StoryTags storyTags = StoryTags();

  final StoryQl storyQl = StoryQl(
      core: true,
      storyUser: storyUser,
      storyOriginalUser: storyOriginalUser,
      storyComments: storyComments,
      storyReactions: storyReactions,
      storyTags: storyTags);

  final StorySearch storySearch = StorySearch.init(
    graphQLClient,
    storyQl,
    'bartonhammond@gmail.com',
  );
  final Map searchValues = <String, dynamic>{
    'currentUserEmail': 'bartonhammond@gmail.com',
    'limit': '10',
    'cursor': '2022-01-01'
  };
  final List stories = await storySearch.getList(searchValues);
  for (var story in stories) {
    printJson('${story["id"]}', story);
  }
}
