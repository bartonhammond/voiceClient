import 'dart:async';
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
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:graphql/client.dart';
import 'graphQL.dart' as graphql;
import 'steps/expectTextFormFieldToHaveValue.dart';
import 'steps/tap_positional_widget_of_type.dart';

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('uri', help: 'the uri');

  parser.addOption(
    'deleteTestUser',
    help: 'delete the test user',
    allowed: ['yes', 'no'],
  );

  parser.addOption(
    'deleteBook',
    help: 'delete the book?',
    allowed: ['yes', 'no'],
  );

  parser.addOption(
    'deleteBooksMessages',
    help: 'delete the Books User Messages?',
    allowed: ['yes', 'no'],
  );
  parser.addOption(
    'deleteBanned',
    help: 'delete the banned?',
    allowed: ['yes', 'no'],
  );

  parser.addOption(
    'deleteFamilyTestUsers',
    help: 'delete the users created for testing family?',
    allowed: ['yes', 'no'],
  );

  parser.addOption(
    'deleteStoryReactions',
    help: 'delete the stories reactions created from eighth?',
    allowed: ['yes', 'no'],
  );
  parser.addOption(
    'runTag',
    help: 'which tag to run?',
    allowed: [
      'all',
      'first',
      'second',
      'third',
      'fourth',
      'fifth',
      'sixth',
      'seventh',
      'eighth'
    ],
  );

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);
  print('uri: ${argResults["uri"]}');
  print('deleteTestUser ${argResults["deleteTestUser"] == "yes"}');
  print('deleteBook ${argResults["deleteBook"] == "yes"}');
  print('deleteBooksMessages ${argResults["deleteBooksMessages"] == "yes"}');
  print('deleteBanned ${argResults["deleteBanned"] == "yes"}');
  print('deleteStoryReactions ${argResults["deleteStoryReactions"] == "yes"}');
  print(
      'deleteFamilyTestUsers ${argResults["deleteFamilyTestUsers"] == "yes"}');
  print('runTag ${argResults["runTag"]}');
  final GraphQLClient graphQLClient =
      graphql.getGraphQLClient(GraphQLClientType.ApolloServer);

  if (argResults['deleteTestUser'] == 'yes' &&
      argResults['deleteBook'] == 'yes') {
    Map<String, dynamic> result = await graphql.getUserByName(
        graphQLClient, 'Test Name', 'bartonhammond@gmail.com');
    if (result != null) {
      final String toId = result['id'];
      result = await graphql.getUserByName(
          graphQLClient, 'Book Name', 'bartonhammond@gmail.com');
      if (result != null) {
        final String fromId = result['id'];
        await graphql.quitFriendship(graphQLClient, toId, fromId);
      }
    }
  }
  if (argResults['deleteTestUser'] == 'yes') {
    await graphql.deleteBookByName(
      graphQLClient,
      'Test Name',
    );
  }

  if (argResults['deleteBook'] == 'yes') {
    await graphql.deleteBookByName(
      graphQLClient,
      'Book Name',
    );
  }

  if (argResults['deleteBooksMessages'] == 'yes') {
    await graphql.deleteUserMessagesByName(
      graphQLClient,
      'Book Name',
    );
  }

  if (argResults['deleteBanned'] == 'yes') {
    /*
    await graphql.deleteAllBans(
      graphQLClient,
      'bartonhammond@gmail.com',
    );
    */
  }
  if (argResults['deleteFamilyTestUsers'] == 'yes') {
    await graphql.deleteBookByName(
      graphQLClient,
      'Family Story Provider',
    );
    await graphql.deleteBookByName(
      graphQLClient,
      'Family Story Friend',
    );
  }
  if (argResults['deleteStoryReactions'] == 'yes') {
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
      'limit': '1',
      'cursor': '2022-01-01'
    };
    final List stories = await storySearch.getList(searchValues);

    await graphql.deleteUserReactionToStory(
      graphQLClient,
      'bartonhammond@gmail.com',
      stories[0]['id'],
    );
    final Map<String, dynamic> testNameUser = await graphql.getUserByName(
        graphQLClient, 'Test Name', 'bartonhammond@gmail.com');

    final Map<String, dynamic> bartonNameUser = await graphql.getUserByName(
        graphQLClient, 'Barton Hammond', 'bartonhammond@gmail.com');

    if (testNameUser != null && bartonNameUser != null) {
      await graphql.quitFriendship(
          graphQLClient, testNameUser['id'], bartonNameUser['id']);
    }
    if (testNameUser != null) {
      for (Map message in testNameUser['messagesReceived']) {
        await graphql.deleteMessage(graphQLClient, message['id']);
      }
    }
    for (Map message in bartonNameUser['messagesReceived']) {
      await graphql.deleteMessage(graphQLClient, message['id']);
    }
  }
  final Iterable<StepDefinitionGeneric<World>> steps = [
    expectTextFormFieldToHaveValue(),
    tapPositionalWidgetOfType(),
  ];
  FlutterTestConfiguration config;
  if (argResults['runTag'] == 'all') {
    config = FlutterTestConfiguration.DEFAULT(
      steps,
      featurePath: 'features//**.feature',
      targetAppPath: 'test_driver/app.dart',
    )
      ..restartAppBetweenScenarios = false
      ..targetAppWorkingDirectory = '../'
      ..runningAppProtocolEndpointUri = argResults['uri']
      ..exitAfterTestRun = true;
  } else {
    config = FlutterTestConfiguration.DEFAULT(
      steps,
      featurePath: 'features//**.feature',
      targetAppPath: 'test_driver/app.dart',
    )
      ..restartAppBetweenScenarios = false
      ..tagExpression = '@${argResults["runTag"]}'
      ..targetAppWorkingDirectory = '../'
      ..runningAppProtocolEndpointUri = argResults['uri']
      ..exitAfterTestRun = true;
  }
  return GherkinRunner().execute(config);
}
