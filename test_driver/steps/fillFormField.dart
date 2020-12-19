import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric fillFormField() {
  return given2<String, String, FlutterWorld>(
    'I enter {string} into the field with {string} tooltip',
    (value, tooltip, context) async {
      print('fillFormField value: $value tooltip: $tooltip');
      final SerializableFinder locator = find.byTooltip(tooltip);
      await FlutterDriverUtils.enterText(context.world.driver, locator, value);
    },
  );
}
