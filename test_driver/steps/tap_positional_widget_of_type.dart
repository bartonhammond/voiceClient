import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric tapPositionalWidgetOfType() {
  return given2<String, String, FlutterWorld>(
    RegExp(r'I tap the first {string} of parent type {string}'),
    (type, parentType, context) async {
      await FlutterDriverUtils.tap(
          context.world.driver,
          find.descendant(
            of: find.byType(parentType),
            matching: find.byType(type),
            firstMatchOnly: true,
          ));
    },
  );
}
