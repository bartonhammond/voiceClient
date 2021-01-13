import 'dart:async';
import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:args/args.dart';
import 'package:gherkin/gherkin.dart';
import 'package:graphql/client.dart';
import 'graphQL.dart' as graphql;
import 'steps/expectTextFormFieldToHaveValue.dart';

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
    'runTag',
    help: 'which tag to run?',
    allowed: ['all', 'first', 'second', 'third', 'fourth', 'fifth'],
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
  print('runTag ${argResults["runTag"]}');

  final GraphQLClient graphQLClient =
      graphql.getGraphQLClient(GraphQLClientType.ApolloServer);

  if (argResults['deleteTestUser'] == 'yes' &&
      argResults['deleteBook'] == 'yes') {
    Map<String, dynamic> result =
        await graphql.getUserByName(graphQLClient, 'Test Name');
    if (result != null) {
      final String toId = result['id'];
      result = await graphql.getUserByName(graphQLClient, 'Book Name');
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
    await graphql.deleteBanned(
      graphQLClient,
      'bartonhammond@gmail.com',
    );
  }

  final Iterable<StepDefinitionGeneric<World>> steps = [
    expectTextFormFieldToHaveValue(),
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
