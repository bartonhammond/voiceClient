import 'dart:async';
import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:args/args.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:graphql/client.dart';
import 'graphQL.dart' as graphql;
import 'steps/expectTextFormFieldToHaveValue.dart';
import 'steps/tap_positional_widget_of_type.dart';
import 'utils/utility.dart' as utility;

Future<void> main(List<String> arguments) async {
  final parser = ArgParser();
  parser.addOption('uri', help: 'the uri');

  parser.addOption(
    'deleteTests',
    help: 'delete the test data',
    allowed: ['yes', 'no'],
  );

  parser.addOption(
    'runTag',
    help: 'which tag to run?',
    allowed: [
      'allBasic',
      'book',
    ],
  );

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);
  print('uri: ${argResults["uri"]}');
  print('deleteTests ${argResults["deleteTests"] == "yes"}');
  print('runTag ${argResults["runTag"]}');

  final GraphQLClient graphQLClient =
      graphql.getGraphQLClient(GraphQLClientType.ApolloServer);

  if (argResults['deleteTests'] == 'yes') {
    utility.deleteScenarioAllBasic(graphQLClient);
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
