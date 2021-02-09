import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

abstract class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    Key key,
  }) : super(key: key);

  Widget buildCupertinoWidget(BuildContext context);
  Widget buildMaterialWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return buildMaterialWidget(context);
    }
    if (Platform.isIOS) {
      return buildCupertinoWidget(context);
    }
    return buildMaterialWidget(context);
  }
}
