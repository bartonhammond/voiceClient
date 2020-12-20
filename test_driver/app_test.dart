import 'dart:async';
import 'dart:io';
import 'package:MyFamilyVoice/constants/enums.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';
import 'package:graphql/client.dart';

import 'graphQL.dart' as graphql;
import 'steps/expectTextFormFieldToHaveValue.dart';
import 'steps/whenTapQuickWidget.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    print('please pass in the uri');
    exit(1);
  }
  final GraphQLClient graphQLClient =
      graphql.getGraphQLClient(GraphQLClientType.ApolloServer);

  await graphql.deleteBook(graphQLClient, 'something@myfamilyvoice.com');
  await graphql.deleteBookByName(graphQLClient, 'Book Name');

  final Iterable<StepDefinitionGeneric<World>> steps = [
    expectTextFormFieldToHaveValue(),
    whenTapQuickWidget(),
  ];

  final config = FlutterTestConfiguration.DEFAULT(
    steps,
    featurePath: 'features//**.feature',
    targetAppPath: 'test_driver/app.dart',
  )
    //..targetDeviceId = '68E55A48-0FE6-41B0-B94E-27E08DE2D6EB'
    ..restartAppBetweenScenarios = false
    ..targetAppWorkingDirectory = '../'
    ..tagExpression = '@newuser'
    //..targetAppPath = 'test_driver/app.dart'
    //  ..defaultTimeout = Duration(seconds: 2)
    // ..buildFlavor = "staging" // uncomment when using build flavor and check android/ios flavor setup see android file android\app\build.gradle
    // ..targetDeviceId = "all" // uncomment to run tests on all connected devices or set specific device target id
    // ..tagExpression = '@smoke and not @ignore' // uncomment to see an example of running scenarios based on tag expressions
    // ..logFlutterProcessOutput = true // uncomment to see command invoked to start the flutter test app
    // ..verboseFlutterProcessLogs = true // uncomment to see the verbose output from the Flutter process
    // ..flutterBuildTimeout = Duration(minutes: 3) // uncomment to change the default period that flutter is expected to build and start the app within
    ..runningAppProtocolEndpointUri = args[0]

    //     'http://127.0.0.1:51540/bkegoer6eH8=/' // already running app observatory / service protocol uri (with enableFlutterDriverExtension method invoked) to test against if you use this set `restartAppBetweenScenarios` to false
    ..exitAfterTestRun = true; // set to false if debugging to exit cleanly

  return GherkinRunner().execute(config);
}
