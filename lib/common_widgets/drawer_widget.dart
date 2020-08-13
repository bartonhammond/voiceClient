import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:i18n_extension/i18n_widget.dart';
import 'package:provider/provider.dart';

import 'package:voiceClient/common_widgets/platform_alert_dialog.dart';
import 'package:voiceClient/common_widgets/platform_exception_alert_dialog.dart';
import 'package:voiceClient/constants/strings.dart';
import 'package:voiceClient/services/auth_service.dart';
import 'package:voiceClient/constants/mfv.i18n.dart';
import 'package:flag/flag.dart';

Future<void> _signOut(BuildContext context) async {
  try {
    final AuthService auth = Provider.of<AuthService>(context, listen: false);
    await auth.signOut();
  } on PlatformException catch (e) {
    await PlatformExceptionAlertDialog(
      title: Strings.logoutFailed.i18n,
      exception: e,
    ).show(context);
  }
}

Future<void> _confirmSignOut(BuildContext context) async {
  final bool didRequestSignOut = await PlatformAlertDialog(
    title: Strings.logout.i18n,
    content: Strings.logoutAreYouSure.i18n,
    cancelActionText: Strings.cancel.i18n,
    defaultActionText: Strings.yes.i18n,
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
          child: Text(Strings.MFV.i18n),
          decoration: BoxDecoration(
            color: Color(0xff00bcd4),
          ),
        ),
        Card(
          child: ListTile(
            title: Text(Strings.logout.i18n),
            onTap: () {
              _confirmSignOut(context);
            },
          ),
        ),
        Card(
          child: ListTile(
            trailing: Flag(
              'US',
              height: 30,
              width: 30,
            ),
            title: Text(Strings.usLocale.i18n),
            onTap: () {
              I18n.of(context).locale = null;
            },
          ),
        ),
        Card(
          child: ListTile(
            trailing: Flag(
              'ES',
              height: 30,
              width: 30,
            ),
            title: Text(Strings.esLocale.i18n),
            onTap: () {
              I18n.of(context).locale = Locale('es');
            },
          ),
        ),
      ],
    ),
  );
}