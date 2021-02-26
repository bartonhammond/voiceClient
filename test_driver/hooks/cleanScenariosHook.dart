import 'dart:io';

import 'package:gherkin/gherkin.dart';
import 'package:graphql/client.dart';
import '../utils/utility.dart' as utility;

class CleanSceanariosHook extends Hook {
  CleanSceanariosHook(this.graphQLClient);
  GraphQLClient graphQLClient;

  /// The priority to assign to this hook.
  /// Higher priority gets run first so a priority of 10 is run before a priority of 2
  @override
  int get priority => 10;

  /// Run after a step has executed
  @override
  Future<void> onAfterStep(World world, String step, StepResult stepResult) {
    if (stepResult.result != StepExecutionResult.pass) {
      print('$step ${stepResult.result}');
      exit(1);
    }
    return Future.value(null);
  }

  /// Run before a scenario and it steps are executed
  @override
  Future<void> onBeforeScenario(
    TestConfiguration config,
    String scenario,
    Iterable<Tag> tags,
  ) async {
    try {
      print("running hook before scenario '$scenario' deleteScenarioAllBasic");
      await utility.deleteScenarioAllBasic(graphQLClient);
    } catch (e) {
      print('deleteScenarioAllBasic failed');
      print(e);
      exit(1);
    }
    try {
      print("running hook before scenario '$scenario' deleteScenarioBook");
      await utility.deleteScenarioBook(graphQLClient);
    } catch (e) {
      print('deleteScenarioBook failed');
      print(e);
      exit(1);
    }
    try {
      print("running hook before scenario '$scenario' deleteDownloads");
      await utility.deleteScenarioDownloads(graphQLClient);
    } catch (e) {
      print('deleteScenarioBook failed');
      print(e);
      exit(1);
    }
  }
}
