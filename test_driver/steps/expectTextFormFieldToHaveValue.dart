import 'package:flutter_driver/flutter_driver.dart';
import 'package:flutter_gherkin/flutter_gherkin.dart';
import 'package:gherkin/gherkin.dart';

StepDefinitionGeneric expectTextFormFieldToHaveValue() {
  return given3<String, String, String, FlutterWorld>(
    'I expect the {string} {string} to be {string}',
    (key, type, value, context) async {
      try {
        final SerializableFinder locator = find.descendant(
            of: find.byValueKey(key), matching: find.byType(type));
        final text =
            await FlutterDriverUtils.getText(context.world.driver, locator);
        context.expect(text, value);
      } catch (e) {
        await context.reporter.message('Step error: $e', MessageLevel.error);
        rethrow;
      }
    },
  );
}
