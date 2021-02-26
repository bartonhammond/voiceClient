import 'dart:async';
import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:args/args.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:graphql/client.dart';
import 'graphQL.dart' as graphql;
import 'hooks/cleanScenariosHook.dart';
import 'steps/expectTextFormFieldToHaveValue.dart';
import 'steps/tap_positional_widget_of_type.dart';

Future<void> main(List<String> arguments) async {
  print('har');
  final parser = ArgParser();
  parser.addOption('uri', help: 'the uri');

  if (arguments == null || arguments.isEmpty) {
    print('missing arguments');
    print(parser.usage);
    exit(1);
  }
  final ArgResults argResults = parser.parse(arguments);
  print('uri: ${argResults["uri"]}');

  final GraphQLClient graphQLClient =
      graphql.getGraphQLClient(GraphQLClientType.ApolloServer);

  final Iterable<StepDefinitionGeneric<World>> steps = [
    expectTextFormFieldToHaveValue(),
    tapPositionalWidgetOfType(),
  ];

  FlutterTestConfiguration config;

  config = FlutterTestConfiguration.DEFAULT(
    steps,
    featurePath: 'features//**.feature',
    targetAppPath: 'test_driver/app.dart',
  )
    ..order = ExecutionOrder.sorted
    ..restartAppBetweenScenarios = false
    ..targetAppWorkingDirectory = '../'
    ..runningAppProtocolEndpointUri = argResults['uri']
    ..exitAfterTestRun = true
    ..hooks = [
      CleanSceanariosHook(graphQLClient),
    ];

  return GherkinRunner().execute(config);
}
