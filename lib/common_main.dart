// Fix for: Unhandled Exception: ServicesBinding.defaultBinaryMessenger was accessed before the binding was initialized.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shake_flutter/shake_flutter.dart';

void setup() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIOverlays([]);
  ResponsiveSizingConfig.instance.setCustomBreakpoints(ScreenBreakpoints(
    desktop: 950,
    tablet: 600,
    watch: 325,
  ));
  Shake.setShowFloatingReportButton(true);
  Shake.setInvokeShakeOnShakeDeviceEvent(true);
  Shake.setInvokeShakeOnScreenshot(true);
  Shake.start();
}
