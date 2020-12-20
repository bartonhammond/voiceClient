import 'package:flutter_gherkin/src/flutter/flutter_world.dart';
import 'package:flutter_driver/flutter_driver.dart';
import 'package:gherkin/gherkin.dart';

import '../utils/driver_utils.dart';

StepDefinitionGeneric whenTapQuickWidget() {
  return when1<String, FlutterWorld>(
    RegExp(
        r'I quickly tap the {string} (?:button|element|label|icon|field|text|widget)$'),
    (key, context) async {
      final finder = find.byValueKey(key);

      await context.world.driver.scrollIntoView(
        finder,
      );
      await FlutterDriverUtilsExtension.tapQuick(
        context.world.driver,
        finder,
      );
    },
  );
}
