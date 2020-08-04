import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/platform_exception_alert_dialog.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/auth_service.dart';

Future<void> _signOut(BuildContext context) async {
  try {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  } on PlatformException catch (e) {
    await PlatformExceptionAlertDialog(
      title: Strings.logoutFailed,
      exception: e,
    ).show(context);
  }
}

Future<void> _confirmSignOut(BuildContext context) async {
  final bool didRequestSignOut = await PlatformAlertDialog(
    title: Strings.logout,
    content: Strings.logoutAreYouSure,
    cancelActionText: Strings.cancel,
    defaultActionText: Strings.logout,
  ).show(context);
  if (didRequestSignOut == true) {
    _signOut(context);
  }
}

Widget getDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text(Strings.MFV),
          decoration: BoxDecoration(
            color: NeumorphicTheme.currentTheme(context).variantColor,
          ),
        ),
        ListTile(
          title: Text(Strings.logout),
          onTap: () {
            _confirmSignOut(context);
          },
        ),
      ],
    ),
  );
}
