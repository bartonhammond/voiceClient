import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric widgetOfType() {
  return given1<String, FlutterWorld>(
    'I expect the widget of type {string} to be present',
    (type, context) async {
      final SerializableFinder locator = find.byType(type);
      await FlutterDriverUtils.isPresent(context.world.driver, locator);
    },
  );
}
